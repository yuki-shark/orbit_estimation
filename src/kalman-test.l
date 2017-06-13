#!/usr/bin/env roseus

(ros::roseus "hoge")
(ros::load-ros-manifest "opencv_apps")

(load "~/prog/euslib/jsk/kalmanlib.l")

(setq *z* nil)
(defun cb (msg)
  (let (tm cen z z^ max max_num)
    (setq max 0)
    (setq max_num -1)

    (dotimes (i (length (send msg :moments)))
      (let* ((moment-nth-i (nth i (send msg :moments))))
        (when (and (not (c-isnan (send moment-nth-i :center :x)))
                   (> (send moment-nth-i :area) max))
          (setq max (send moment-nth-i :area))
          (setq max_num i))))

    (when (> max_num 0)
      (setq tm (send msg :header :stamp)
            cen (send (nth max_num (send msg :moments)) :center))
      (print (list tm (send cen :x) (send cen :y)))

      ;; (send k :proc)
      (setq z (float-vector (send cen :x) (send cen :y)))
      (setq *z* z)
      ;;(setq z^ (send k :proc z)) ;; OK
      ;;n(send k :correct z)
      ;;(setq z^ (transform (k . H) (k . x_k)))
      ;;(format t "~A ~A ~A~%" (elt z^ 0) (elt z^ 1) (send k :error))
    )))

;(setq k (instance kalman-filter :init :state-dim 2))
(setq k (instance kalman-filter :init :state-dim 4 :r-variance 0.001))
(send k :A #2f((1 0 1 0)(0 1 0 1)(0 0 1 0)(0 0 0 1)))))
;; (send k :u #f(0 0 0 1e-4))
;;(send k :u #f(0 0 0 1e-4))

(ros::subscribe "/left_opencv_centroid/moments" opencv_apps::MomentArrayStamped #'cb 10)
(ros::advertise "/moments_filtered/x" std_msgs::Float64)
(ros::advertise "/moments_filtered/y" std_msgs::Float64)
(ros::rate 10)
(while (ros::ok)
  (print "spin")
  (when *z*
    (setq z^ (send k :proc *z*))
    (setq *z* nil)
    ;;(send k :predict)
    (setq z^ (transform (k . H) (k . x_k)))
    (print z^)
    (ros::publish "/moments_filtered/x" (instance std_msgs::Float64 :init :data (elt z^ 0)))
    (ros::publish "/moments_filtered/y" (instance std_msgs::Float64 :init :data (elt z^ 1)))
    )
  (ros::spin-once)
  (ros::sleep))
