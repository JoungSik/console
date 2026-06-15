module Journal
  class PostsController < ApplicationController
    before_action :set_post, only: %i[show edit update destroy]

    def index
      @post = Post.new
      @posts = current_user_posts.recent
    end

    def show
    end

    def edit
    end

    def create
      @post = Post.new(post_params)

      if @post.save
        redirect_to posts.root_path, notice: "포스트가 생성되었습니다."
      else
        @posts = current_user_posts.recent
        render :index, status: :unprocessable_entity
      end
    end

    def update
      if @post.update(post_params)
        redirect_to posts.post_path(@post), notice: "포스트가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy!
      redirect_to posts.root_path, status: :see_other, notice: "포스트가 삭제되었습니다."
    end

    private

    def set_post
      @post = current_user_posts.find(params[:id])
    end

    def current_user_posts
      Post.by_user(current_user_id)
    end

    def post_params
      params.require(:post).permit(:body).merge(user_id: current_user_id)
    end
  end
end
