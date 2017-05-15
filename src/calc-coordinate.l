#!/usr/bin/env roseus

;(load "package://roseus/euslisp/roseus-utils.l")

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")

(defun callback-left (msg)
  (setq *left-msg* msg)
  )
(defun callback-right (msg)
  (setq *right-msg* msg)
  )

(setq *left-camera-info* nil)
(setq *right-camera-info* nil)
(defun callback-left-camerainfo (msg)
  (setq *left-camera-info* msg))
(defun callback-right-camerainfo (msg)
  (setq *right-camera-info* msg))

(defun calc-coordinate ()
  (ros::roseus "calc-coordinate")
  (ros::advertise "centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped)

  (ros::subscribe "/pointgrey/left/camera_info"
                  sensor_msgs::camerainfo
                  #'callback-left-camerainfo 1)
  (ros::subscribe "/pointgrey/right/camera_info"
                  sensor_msgs::camerainfo
                  #'callback-right-camerainfo 1)

  (let ((st (ros::time-now)))
    (while (not (and *left-camera-info*
                     *right-camera-info*))
      (when (> (send (ros::time- (ros::time-now) st) :to-sec) 10.0)
        (warn ";; timeout, camera-info not found~%")
        (return-from calc-coordinate nil))
      (unix::usleep (* 1000 100));; sleep 100 ms
      (ros::spin-once)
      )
    )

  (warn ";; found camera-info~%")
  (let (c1 c2 left_m right_m
       sp1 sp2 header max
       pwidth pheight p)

    (setq pwidth (send *left-camera-info* :width))
    (setq pheight (send *left-camera-info* :height))
    (setq p (send *left-camera-info* :P))
    (setq c1 (make-camera-from-ros-camera-info-aux pwidth pheight p nil))

    (setq pwidth (send *right-camera-info* :width))
    (setq pheight (send *right-camera-info* :height))
    (setq p (send *right-camera-info* :P))
    (setf (elt p 3)
          (* (/ (elt p 3) (elt p 0)) 1000.0))
    (setq c2 (make-camera-from-ros-camera-info-aux pwidth pheight p nil))

    (send c1 :assoc c2)

    (ros::subscribe "/left_opencv_centroid/moments"
                    opencv_apps::MomentArrayStamped
                    #'callback-left)

    (ros::subscribe "/right_opencv_centroid/moments"
                    opencv_apps::MomentArrayStamped
                    #'callback-right)

    (while (ros::ok)

      ;; get object position in image coordinates
      (setq *left-msg* nil)
      (setq *right-msg* nil)
      (ros::spin-once)

      (when (or *left-msg* *right-msg*)
        (if *left-msg*
            (setq left_m *left-msg*))
        (if *right-msg*
            (setq right_m *right-msg*))
        (print ";; msg received~%")
        ;calc centroid from left_m and right_m
        ; :length *****
        ;(print "slots")
        ;(print (send left_m :slots))
        ;(print "moments")
        ;(print (send left_m :moments))
        ;; (print-ros-msg left_m)
        ;; (send left_m :methods)
        ;; (print-ros-msg left_m :ro ros::moments)
        ;; (print (send left_m :moments :area))
        ;; (setq left_len (length (send left_m :moments)))
        (setq max 0)
        ;; (print ";; left_len= ~A ~%" left_len)
        (setq left_len (length (send left_m :moments)))
        (print left_len)

        ;(print (send (nth 1 (send left_m :moments)) :area))
        (dotimes (i left_len)
          (when (> (send (nth i (send left_m :moments)):area) max)
            (setq max (send (nth i (send left_m :moments)):area))))
        (setq sp1 (send (nth max (send left_m :moments)) :center))

        (print "sp1")
        (print sp1)

        (setq max 0)
        (setq right_len (length (send right_m :moments)))

        ;(print (send (nth 1 (send right_m :moments)) :area))
        (dotimes (i right_len)
          (when (> (send (nth i (send right_m :moments)):area) max)
            (setq max (send (nth i (send right_m :moments)):area))))
        (setq sp2 (send (nth max (send right_m :moments)) :center))

        ;;calc mean_y
        (when (and sp1 sp2)
          (setq mean_y (+ (send sp1 :point :y) (send sp2 :point :y)))
          (when (c-isnan mean_y)
            ;;
            )
          (setq header (send sp1 :header))
          (send sp1 :point :y mean_y)
          (send sp2 :point :y mean_y)

          (setq sp1 (float-vector (send sp1 :point :x)
                                  (send sp1 :point :y)))
          (setq sp2 (float-vector (send sp2 :point :x)
                                  (send sp2 :point :y)))
          ;;(pprint (list sp1 sp2))
          ;; get ray of found objects
          (setq r1 (send c1 :ray (elt sp1 0) (elt sp1 1)))
          (setq l1 (make-line (send c1 :worldpos) (v+ (send c1 :worldpos) (scale 5000 r1))))
          (setq r2 (send c2 :ray (elt sp2 0) (elt sp2 1)))        ;; get ray
          (setq l2 (make-line (send c2 :worldpos) (v+ (send c2 :worldpos) (scale 5000 r2)))) ;; make line

          (let ((ln (send l1 :common-perpendicular l2))) ;; end-points of the line vertical both to l1 and l2
            (unless (eq ln :parallel)
              (setq p (apply #'midpoint 0.5
                             (send l1 :common-perpendicular l2)))
              ;(pprint p)
              (setq msg (instance geometry_msgs::PointStamped :init
                                  :header header
                                  :point
                                  (instance geometry_msgs::Point :init
                                            :x (elt p 0)
                                            :y (elt p 1)
                                            :z (elt p 2))))
              (ros::publish "centroid_calc_from_stereo_image" msg)
              ))
          (setq sp1 nil)
          (setq sp2 nil)
          )
        )
      (unix::usleep (* 1000 10));; 10ms
      )
    )
  )

;(warn ";; run demo program~%")
(warn "(calc-coordinate)~%")
(calc-coordinate)
