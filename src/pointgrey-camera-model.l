#!/usr/bin/env roseus

;(ros::load-ros-manifest "roseus")
;(ros::roseus "calc-coordinate")
;(ros::advertise "centorid_calc_from_stereo_image")

(defclass pointgrey-camera-model
  :super cascaded-link
  :slots (camera))

(defmethod pointgrey-camera-model
  (:init (caminfo)
    (let (pwidth pheight p)
      (send-super :init)
      ;;pointgrey camera
      ;; (ros::subscribe "/camera_info" sensor_msgs::CameraInfo #'(lambda (msg)
      ;;     (let ((pwidth (send msg :width))
      ;;          (pheight (send msg :height))
      ;;          (p (send msg :P)))
      ;;      ;; FIXME:: add coordinates of camera
      ;;      (format t " (make-camera-from-ros-camera-info-aux ~A ~A ~A nil)"pwidth pheight p)
      ;;      (make-camera-from-ros-camera-info-aux pwidth pheight p nil)))
      (setq pwidth (send *camera_info* :width))
      (setq pheight (send *camera_info* :height))
      (setq p (send *camera_info* :P))
      (setq c1 (make-camera-from-ros-camera-info-aux pwidth pheight p nil))

      (send self :init-ending)
      self)))
