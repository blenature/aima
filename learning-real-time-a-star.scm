#!/usr/bin/env chicken-scheme

;; [[file:~/prg/scm/aima/aima.org::*4.13][4\.13:1]]

(include "online-navigation.scm")
(use heap)

;;; Let's keep track of the goal and visualize a straight-line
;;; heuristic thither in light grey (with the updated distance) for
;;; those states for which we have information.
(define (make-agent-lrta* start next-frame)
  (make-agent
   start
   0
   (let ((result (make-hash-table))
         (cost-estimate (make-hash-table))
         (previous-state #f)
         (previous-action #f))
     (define (lrta*-cost previous-state previous-action state)
       (if state
           (+ (point-distance origin previous-action)
              (hash-table-ref cost-estimate state))
           0))
     ;; This is slow in the sense that we create hash-tables for every
     ;; non-existent entry; or not? Default memoizes, I think.
     (define (result-ref state action)
       (hash-table-ref/default
        (hash-table-ref/default
         result
         state
         (make-hash-table))
        action
        #f))
     (lambda (state goal? score)
       (if goal?
           (begin
             (set! previous-state #f)
             (set! previous-action #f)
             zero-motion)
           (begin
             (unless (hash-table-exists? cost-estimate state)
               ;; We could refine this by providing the Euclidian
               ;; distance, if we have one.
               (hash-table-set! cost-estimate state 0))
             (when previous-state
               (hash-table-update!/default
                result
                previous-state
                (lambda (action->state)
                  (hash-table-set!
                   action->state
                   previous-action
                   state)
                  action->state)
                (make-hash-table))
               (let ((minimum-cost
                      (apply
                       min
                       (map (lambda (action)
                              (lrta*-cost
                               previous-state
                               action
                               (result-ref previous-state action)))
                            previous-state))))
                 (debug minimum-cost)
                 (hash-table-set! cost-estimate previous-state minimum-cost)))
             (let ((actions (make-min-heap)))
               (for-each (lambda (action)
                           (heap-insert! actions
                                         (lrta*-cost state action (result-ref state action))
                                         action))
                 state)
               ;; (debug (heap->alist actions))
               (let ((action (heap-extremum actions)))
                 (set! previous-action action)
                 (set! previous-state state)
                 action))))))))

(simulate-navigation make-agent-lrta*
                     n-nodes: 100
                     n-steps: 100
                     )

;; 4\.13:1 ends here