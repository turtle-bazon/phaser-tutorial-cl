;;;; -*- mode: lisp -*-

(in-package #:phaser-tutorial-cl)

(defun compile-parens ()
  (let ((sources '("paren/phaser.paren" "public/js/phaser.cl.js"
                   "paren/phaser-tutorial-cl.paren" "public/js/main.js")))
    (loop for (source output) on sources by #'cddr
       do (with-open-file (s output :direction :output
                             :if-exists :overwrite :if-does-not-exist :create)
            (paren-files:compile-script-file source :output-stream s)))))

(defvar *acceptor* (make-instance 'easy-acceptor :port 8080))

(setf *dispatch-table* (list 'dispatch-easy-handlers
                             (create-folder-dispatcher-and-handler "/" "public/")))

(define-easy-handler (root :uri "/") ()
  (with-open-file (stream "public/index.html")
    (let ((data (make-string (file-length stream))))
      (read-sequence data stream)
      data)))

(compile-parens)
