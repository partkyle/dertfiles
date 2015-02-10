;; /usr/local/bin
(setq exec-path (append exec-path '("/usr/local/bin")))

;; load-path
(add-to-list 'load-path "~/.emacs.d/vendor/")
(add-to-list 'load-path "~/.emacs.d/vendor/go-mode.el")

; Stop Emacs from losing undo information by
; setting very high limits for undo buffers
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

;; this needs to run first for when I eventually
;; break something
(global-set-key
 [f7]
 (lambda () (interactive)
   (find-file "~/.emacs.d/init.el" t)))

(defun jmc-eval-to-here ()
  (interactive)
  (eval-region 0 (point)))
(global-set-key
 [f8]
 'jmc-eval-to-here)

;; redo last command
(defun describe-last-function ()
  (interactive)
  (describe-function last-command))

;; the bell is evil
(setq ring-bell-function 'ignore)

;; newline-and-indent
(define-key global-map (kbd "RET") 'newline-and-indent)

;; change to split after creation
(defadvice split-window (after move-point-to-new-window activate)
  "Moves the point to the newly created window after splitting."
  (other-window 1))

;; make sure all packages are loaded
(require 'cl)
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("ELPA" . "http://tromey.com/elpa/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; look and feel
(if window-system
    (progn
      (set-frame-font "M+ 2m")
      (set-face-attribute 'default nil :height 160)
      (delete-selection-mode t)
      (tool-bar-mode -1)
      (menu-bar-mode -1)
      (blink-cursor-mode -1)
      (scroll-bar-mode -1)
	  (color-theme-cobalt)))

;; highlight line
(global-hl-line-mode 1)

(setq inhibit-startup-message t)
(show-paren-mode t)
(column-number-mode t)

;; expand region
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(fset 'yes-or-no-p 'y-or-n-p)

(setq make-backup-files nil)
(setq auto-save-default nil)

;; tab settings
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; ido settings (fuzzy finder)
(when (require 'ido)
  (ido-mode t)
  (setq ido-max-directory-size 10000
        Ido-enable-flex-matching t)) ;; enable fuzzy matching

;; (require 'helm-config)
;; (helm-mode 1)

;; smart tabs
(require 'smart-tab)
(add-hook 'prog-mode-hook #'smart-tab-mode)

(when (require 'smex)
  (global-set-key (kbd "M-x") 'smex))

;; auto-complete
(require 'auto-complete)
(require 'auto-complete-config)

;; go-mode
(require 'go-mode-autoloads)
(require 'go-autocomplete)
(require 'flymake-go)

(set 'gofmt-command "goimports")

(global-set-key (kbd "M-<left>") 'previous-buffer)
(global-set-key (kbd "M-<right>") 'next-buffer)

(add-hook 'go-mode-hook (lambda ()
						  (flymake-mode)
						  (auto-complete-mode)
              (go-eldoc-setup)
              (add-hook 'before-save-hook 'gofmt-before-save)
              (setq-default tab-width 4)
              (setq-default indent-tabs-mode t)
              (local-set-key (kbd "M-.") 'godef-jump)
						  (local-set-key (kbd "C-c C-c") 'recompile)))


(add-to-list 'load-path "/usr/local/src/rust/src/etc/emacs/")
(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(setq racer-rust-src-path "/usr/local/src/rust/src/")
(setq racer-cmd "~/code/racer/target/racer")
(add-to-list 'load-path "~/code/racer/editors")
(eval-after-load "rust-mode" '(require 'racer))
