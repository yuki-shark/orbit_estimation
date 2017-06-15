#!/usr/bin/env roseus

(setq *use-file* 0)

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "sensor_msgs")
(ros::roseus-add-msgs "image_view2")

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

(when (eq *use-file* 0)
  (setq *value* (list 0 1024)))
(when (eq *use-file* 316)
  (setq *value* (list 700 700)))

(defun calc-coordinate ()
  (ros::roseus "calc-coordinate")
  (ros::advertise "centroid_calc_from_stereo_image"
                  geometry_msgs::PointStamped)
  (ros::advertise "sp1"
                  opencv_apps::Point2DStamped)
  (ros::advertise "sp2"
                  opencv_apps::Point2DStamped)
  (ros::advertise "/left_image/image_marker"
                  image_view2::ImageMarker2)
  (ros::advertise "/right_image/image_marker"
                  image_view2::ImageMarker2)

  (ros::subscribe "/left_opencv_centroid/moments"
                  opencv_apps::MomentArrayStamped
                  #'callback-left)

  (ros::subscribe "/right_opencv_centroid/moments"
                  opencv_apps::MomentArrayStamped
                  #'callback-right)

  (ros::subscribe "/pointgrey/left/camera_info"
                  sensor_msgs::camerainfo
                  #'callback-left-camerainfo 1)
  (ros::subscribe "/pointgrey/right/camera_info"
                  sensor_msgs::camerainfo
                  #'callback-right-camerainfo 1)
  (unix::usleep (* 1000 1000))
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
  (let (c1 c2 left_m right_m left_len right_len
       sp1 sp2 header max max_num
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

    (while (ros::ok)

      ;; get object position in image coordinates
      (setq *left-msg* nil)
      (setq *right-msg* nil)
      ;(setq sp1 nil)
      ;(setq sp2 nil)
      (ros::spin-once)

      (when (or *left-msg* *right-msg*)
        (when *left-msg*
            (setq left_m *left-msg*)
            (setq header (send left_m :header))

            (when (send left_m :moments)
              (setq max 0)
              (setq max_num -1)
              (setq left_len (length (send left_m :moments)))

              (dotimes (i left_len)
                (let* ((moment-nth-i (nth i (send left_m :moments))))
                  (when (and (not (c-isnan (send moment-nth-i :center :x)))
                             (> (send moment-nth-i :area) max)
                             (> (send moment-nth-i :center :x) (car *value*))
                             (< (send moment-nth-i :center :y) (cadr *value*)))
                  (setq max (send moment-nth-i :area))
                  (setq max_num i))))

              (when (> max_num -1)
                (setq sp1 (instance opencv_apps::Point2DStamped :init
                                    :point
                                    (send (nth max_num (send left_m :moments)) :center)))
                (print "sp1")
                (print (send sp1 :point :x))
                (print (send sp1 :point :y))

                (let ((msg-mk (instance image_view2::ImageMarker2 :init :id 0
                                        :type image_view2::ImageMarker2::*circle*
                                        :scale 10 :width 2)))
                  (send msg-mk :position :x (send sp1 :point :x))
                  (send msg-mk :position :y (send sp1 :point :y))
                  (ros::publish "/left_image/image_marker" msg-mk)
                  )
                )
              ))
        (when *right-msg*
            (setq right_m *right-msg*)
            (when (send right_m :moments)
              (setq max 0)
              (setq max_num -1)
              (setq right_len (length (send right_m :moments)))

              (dotimes (i right_len)
                (let* ((moment-nth-i (nth i (send right_m :moments))))
                  (when (and (not (c-isnan (send moment-nth-i :center :x)))
                             (> (send moment-nth-i :area) max)
                             (> (send moment-nth-i :center :x) (car *value*))
                             (< (send moment-nth-i :center :y) (cadr *value*)))
                  (setq max (send moment-nth-i :area))
                  (setq max_num i))))

              (when (> max_num -1)
                (setq sp2 (instance opencv_apps::Point2DStamped :init
                                    :point
                                    (send (nth max_num (send right_m :moments)) :center)))
                (print "sp2")
                (print (send sp2 :point :x))
                (print (send sp2 :point :y))

                (let ((msg-mk (instance image_view2::ImageMarker2 :init :id 0
                                        :type image_view2::ImageMarker2::*circle*
                                        :scale 10 :width 2)))
                  (send msg-mk :position :x (send sp2 :point :x))
                  (send msg-mk :position :y (send sp2 :point :y))
                  (ros::publish "/right_image/image_marker" msg-mk)
                  )
                )
              ))

        (print ";; msg received~%")

        ;;calc mean_y
        (when (and sp1 sp2)
          (setq mean_y (/ (+ (send sp1 :point :y) (send sp2 :point :y)) 2.0))
          (when (c-isnan mean_y)
            ;;
          )
          ;(setq header (send sp1 :header))
          (send sp1 :point :y mean_y)
          (send sp2 :point :y mean_y)
          (print (send sp1 :point :y))
          (print (send sp2 :point :y))

          (setq sp1-x (send sp1 :point :x))
          (setq sp1-y (send sp1 :point :y))
          (setq sp2-x (send sp2 :point :x))
          (setq sp2-y (send sp2 :point :y))

          (setq sp1 (float-vector (send sp1 :point :x)
                                  (send sp1 :point :y)))
          (setq sp2 (float-vector (send sp2 :point :x)
                                  (send sp2 :point :y)))

          ;; get ray of found objects
          (setq r1 (send c1 :ray (elt sp1 0) (elt sp1 1)))
          (setq l1 (make-line (send c1 :worldpos) (v+ (send c1 :worldpos) (scale 5000 r1))))
          (setq r2 (send c2 :ray (elt sp2 0) (elt sp2 1)))        ;; get ray
          (setq l2 (make-line (send c2 :worldpos) (v+ (send c2 :worldpos) (scale 5000 r2)))) ;; make line

          (let ((ln (send l1 :common-perpendicular l2))) ;; end-points of the line vertical both to l1 and l2
            (unless (eq ln :parallel)
              (setq p (apply #'midpoint 0.5
                             (send l1 :common-perpendicular l2)))
              (setq msg (instance geometry_msgs::PointStamped :init
                                  :header header
                                  :point
                                  (instance geometry_msgs::Point :init
                                            :x (* (elt p 0) 0.001)
                                            :y (* (elt p 1) 0.001)
                                            :z (* (elt p 2) 0.001))))
              (ros::publish "centroid_calc_from_stereo_image" msg)

              (setq sp1-msg (instance opencv_apps::Point2DStamped :init
                                  :header header
                                  :point
                                  (instance opencv_apps::Point2D :init
                                            :x sp1-x
                                            :y sp1-y)))

              (setq sp2-msg (instance opencv_apps::Point2DStamped :init
                                  :header header
                                  :point
                                  (instance opencv_apps::Point2D :init
                                            :x sp2-x
                                            :y sp2-y)))

              (ros::publish "sp1" sp1-msg)
              (ros::publish "sp2" sp2-msg)
              ))
          (setq sp1 nil)
          (setq sp2 nil)
          )
        )
      (unix::usleep (* 1000 10));; 10ms
      )
    )
  )

(warn "(calc-coordinate)~%")
(calc-coordinate)
