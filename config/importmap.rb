# Pin npm packages by running ./bin/importmap

pin "application"
pin "service_worker_registration"
pin "firebase_messaging"
pin "push_registration_client"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/hotwire-native-bridge", to: "@hotwired--hotwire-native-bridge.js" # @1.2.2

pin "js_admin", to: "js_admin/application.js", preload: true
pin "js_admin/controllers/theme_controller", to: "js_admin/controllers/theme_controller.js", preload: true
pin "js_admin/controllers/flash_controller", to: "js_admin/controllers/flash_controller.js", preload: true
pin "firebase/app", to: "https://www.gstatic.com/firebasejs/12.17.1/firebase-app.js" # @12.17.1
pin "firebase/messaging", to: "https://www.gstatic.com/firebasejs/12.17.1/firebase-messaging.js" # @12.17.1
