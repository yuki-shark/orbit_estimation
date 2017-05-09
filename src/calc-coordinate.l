(defun sample-robot-camera ()
  (let (r b g c1 c2)
    (load "irteus/demo/sample-robot-model.l")
    (setq r (instance sample-robot :init))
    (send r :fix-leg-to-coords (make-coords))
    (setq b (make-cube 100 100 100 :pos #f(1000 1000 1000)))
    (send b :set-color :red)
    (setq g (make-cube 3000 3000 1))
    (send g :set-color :gray90)
    (objects (list r b g))

    ;; get camera model
    (setq c1 (send r :camera "left-camera"))
    (setq c2 (send r :camera "right-camera"))

    ;; display coordinates
    (send (send c1 :copy-worldcoords) :draw-on :flush t :size 1000)

    ;; display view
    (send c1 :draw-on :flush t)

    ;; get view angle
    (format t "view-angle ~A [deg]~%" (rad2deg (send c1 :viewing :view-angle)))

    ;; display view image
    (send c1 :draw-objects (list b g))
    ;; save view image
    (image::write-png-file "camera-image.png" (send c1 :get-image))

    ;; git object position in image coordinates
    (setq sp1 (send c1 :screen-point (send b :worldpos)))
    (format t "screen point ~A (left)~%" sp1)

    ;; get ray of found objects
    (setq r1 (send c1 :ray (elt sp1 0) (elt sp1 1)))
    (setq l1 (make-line (send c1 :worldpos) (v+ (send c1 :worldpos) (scale 2000 r1))))
    (send l1 :draw-on :flush t)
    (objects l1)
    (format t "r1 ~A (left)~%" r1)

    ;; stereo proceessing
    (setq sp2 (send c2 :screen-point (send b :worldpos))) ;; get image coordinates
    (setq r2 (send c1 :ray (elt sp2 0) (elt sp2 1)))        ;; get ray
    (setq l2 (make-line (send c2 :worldpos) (v+ (send c2 :worldpos) (scale 2000 r2)))) ;; make line
    (objects l2)
    (send l1 :common-perpendicular l2) ;; end-points of the line vertical both to l1 and l2
    (setq p (apply #'midpoint 0.5 (send l1 :common-perpendicular l2)))
    ;;
    (format t "p ~A (left)~%" p)
    (format t "check  stereo processing ~A~%" (eps-v= (send b :worldpos) p)) ;; check
    ))

(warn ";; run demo program~%")
(warn "(sample-robot-camera)~%")
