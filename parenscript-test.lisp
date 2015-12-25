;;;; -*- mode: lisp -*-

(defpackage #:parenscript-test
  (:use #:cl
        #:hunchentoot
        #:cl-who
        #:parenscript))

(in-package #:parenscript-test)

(defvar *acceptor* (make-instance 'easy-acceptor :port 8080))

(setf *dispatch-table* (list 'dispatch-easy-handlers
                             (create-folder-dispatcher-and-handler "/" "public/")))

(define-easy-handler (root :uri "/") ()
  (with-open-file (stream "public/index.html")
    (let ((data (make-string (file-length stream))))
      (read-sequence data stream)
      data)))

(define-easy-handler (main-js :uri "/js/main.js") ()
  (setf (content-type*) "text/javascript")
  (ps
    (defvar *platforms* nil)

    (defvar *player* nil)

    (defvar *cursors* nil)

    (defvar *stars* nil)

    (defvar *score* 0)

    (defvar *score-text* nil)
    
    (defun init ()
      (defun preload-fn ()
        (chain game load (image "sky" "assets/sky.png"))
        (chain game load (image "ground" "assets/platform.png"))
        (chain game load (image "star" "assets/star.png"))
        (chain game load (spritesheet "dude" "assets/dude.png" 32 48))
        nil)
      (defun create-fn ()
        (chain game physics (start-system (chain *Phaser *Physics *ARCADE*)))
        (chain game add (sprite 0 0 "sky"))
        (setf *platforms* (chain game add (group)))
        (setf (chain *platforms* enable-body) t)
        (let ((ground (chain *platforms* (create 0 (- (chain game world height) 64) "ground")))
              (ledge nil))
          (chain ground scale (set-to 2 2))
          (setf (chain ground body immovable) t)
          (setf ledge (chain *platforms* (create 400 400 "ground")))
          (setf (chain ledge body immovable) t)
          (setf ledge (chain *platforms* (create -150 250 "ground")))
          (setf (chain ledge body immovable) t)
          (setf *player* (chain game add (sprite 32 (- (chain game world height) 150) "dude")))
          (chain game physics arcade (enable *player*))
          (setf (chain *player* body bounce y) 0.2)
          (setf (chain *player* body gravity y) 300)
          (setf (chain *player* body collideWorldBounds) t)
          (chain *player* animations (add "left" '(0 1 2 3) 10 t))
          (chain *player* animations (add "right" '(5 6 7 8) 10 t))
          (setf *stars* (chain game add (group)))
          (setf (chain *stars* enable-body) t)
          (dotimes (i 12)
            (let ((star (chain *stars* (create (* i 70) 0 "star"))))
              (setf (chain star body gravity y) 6)
              (setf (chain star body bounce y) (+ 0.7 (* 0.2 (chain *Math (random))))))))
        (setf *score-text* (chain game add (text 16 16 "Score: 0" (create font-size "32px"
                                                                          fill "#000"))))
        (setf *cursors* (chain game input keyboard (create-cursor-keys)))
        nil)
      (defun update-fn ()
        (chain game physics arcade (collide *player* *platforms*))
        (chain game physics arcade (collide *stars* *platforms*))
        (chain game physics arcade (overlap *player* *stars* collect-star null this))
        (setf (chain *player* body velocity x) 0)
        (cond
          ((chain *cursors* left is-down) (progn (setf (chain *player* body velocity x) -150)
                                                 (chain *player* animations (play "left"))))
          ((chain *cursors* right is-down) (progn (setf (chain *player* body velocity x) 150)
                                                  (chain *player* animations (play "right"))))
          (t (progn (chain *player* animations (stop))
                    (setf (chain *player* frame) 4))))
        (when (and (chain *cursors* up is-down)
                   (chain *player* body touching down))
          (setf (chain *player* body velocity y) -350))
        nil)
      (defun collect-star (player star)
        (chain star (kill))
        (incf *score* 10)
        (setf (chain *score-text* text) (+ "Score: " *score*))
        nil)
      (let ((game (new (chain *Phaser (*Game 800 600 (chain *Phaser *AUTO*)
                                             "game" (create preload preload-fn
                                                            create create-fn
                                                            update update-fn))))))))

    (setf (chain window onload) init))
  )
