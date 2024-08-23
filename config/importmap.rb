# config/importmap.rb

# Pin npm packages by running ./bin/importmap
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "post", to: "post.js"
pin "edit-delete-modal", to: "edit-delete-modal.js"
pin "comment", to: "comment.js"
pin "edit-delete-comment", to: "edit-delete-comment.js"
