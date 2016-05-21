;;; module-eshell.el

(use-package eshell
  :when IS-WINDOWS
  :defer t
  :init
  (evil-set-initial-state 'eshell-mode 'normal)
  (setq eshell-directory-name (concat doom-temp-dir "/eshell")
        eshell-scroll-to-bottom-on-input 'all
        eshell-buffer-shorthand t

        ;; em-glob
        eshell-glob-case-insensitive t
        eshell-error-if-no-glob t

        ;; em-alias
        eshell-aliases-file (concat doom-temp-dir "/.eshell-aliases"))

  ;; plan 9 smart shell
  (require 'em-smart)
  (add-to-list 'eshell-modules-list 'eshell-smart)
  (setq eshell-where-to-jump 'begin)
  (setq eshell-review-quick-commands nil)
  (setq eshell-smart-space-goes-to-end t)

  ;; em-prompt
  (setq eshell-prompt-function 'doom/eshell-prompt)

  (map! :map eshell-mode-map
        :n "i" 'doom/eshell-evil-prepend-maybe
        :n "I" 'doom/eshell-evil-prepend
        :n "a" 'doom/eshell-evil-append-maybe
        :n "A" 'doom/eshell-evil-append
        :n "r" 'doom/eshell-evil-replace-maybe
        :n "R" 'doom/eshell-evil-replace-state-maybe))

(provide 'module-eshell)
;;; module-eshell.el ends here