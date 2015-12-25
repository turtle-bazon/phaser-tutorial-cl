;;;; -*- mode: lisp -*-

(defsystem :parenscript-test
  :depends-on (hunchentoot cl-who parenscript)
  :components ((:file "parenscript-test")))
