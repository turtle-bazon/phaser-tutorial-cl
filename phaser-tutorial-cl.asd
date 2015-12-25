;;;; -*- mode: lisp -*-

(asdf:operate 'asdf:load-op :paren-files)

(defsystem :phaser-tutorial-cl
    :depends-on (hunchentoot cl-who parenscript)
    :components ((:module "src"
                          :components ((:module "phaser"
                                                :components ((:file "package")))
                                       (:file "package")
                                       (:file "core" :depends-on ("package"))))
                 (:module "paren"
                          :components ((:parenscript-file "phaser")))))
