require "hashids"
require "bookmark/version"
require "bookmark/engine"

module Bookmark
  mattr_accessor :hashids_encoder
end
