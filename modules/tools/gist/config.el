;;; tools/gist/config.el

;; NOTE On occasion, the cache gets corrupted, causing wrong-type-argument
;; errors. If that happens, try `+gist/kill-cache'. You may have to restart
;; Emacs.

(def-package! gist
  :commands (gist-list gist-region-or-buffer-private gist-region-or-buffer)
  :config
  (set! :popup "*github:gists*" :size 15 :select t :autokill t)

  ;; evil-ify gist listing
  (set! :evil-state 'gist-list-mode 'normal)
  (map! :map gist-list-menu-mode-map
        :n "RET" #'+gist/open-current
        :n "d"   #'gist-kill-current
        :n "r"   #'gist-list-reload
        :n "c"   #'gist-add-buffer
        :n "y"   #'gist-print-current-url
        :n "b"   #'gist-browse-current-url
        :n "s"   #'gist-star
        :n "S"   #'gist-unstar
        :n "f"   #'gist-fork
        :n "q"   #'quit-window)

  (when (bound-and-true-p shackle-mode)
    (defun +gist*list-render (orig-fn &rest args)
      (funcall orig-fn (car args) t)
      (unless (cadr args)
        (doom-popup-buffer (current-buffer))))
    (advice-add #'gist-list-render :around #'+gist*list-render)))
