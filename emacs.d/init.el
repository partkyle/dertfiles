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

;; change to split after creation
(defadvice split-window (after move-point-to-new-window activate)
  "Moves the point to the newly created window after splitting."
  (other-window 1))

;; TODO(partkyle): all of my todos!
;; FIXME: it doesn't need fixed
;; TODO: NOTHING!
;; IMPORTANT(partkyle): we need to keep this
;; BUG: it's not a bug!
;; XXX: this one too for some reason
(defun partkyle/highlight-todos ()
  (font-lock-add-keywords nil
                          '(("\\<\\(XXX\\|FIXME\\|TODO\\|BUG\\|IMPORTANT\\|NOTE\\):" 1 font-lock-warning-face t)
                            ("\\<\\(XXX\\|FIXME\\|TODO\\|BUG\\|IMPORTANT\\|NOTE\\)(.*):" 1 font-lock-warning-face t))))
(add-hook 'prog-mode-hook 'partkyle/highlight-todos)

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

(global-set-key (kbd "M-<left>") 'previous-buffer)
(global-set-key (kbd "M-<right>") 'next-buffer)
(global-set-key (kbd "M-S-<up>") 'windmove-up)
(global-set-key (kbd "M-S-<down>") 'windmove-down)
(global-set-key (kbd "M-S-<left>") 'windmove-left)
(global-set-key (kbd "M-S-<right>") 'windmove-right)
(global-set-key (kbd "s-o") 'helm-find-files)
(global-set-key (kbd "s-p") 'helm-M-x)
(global-set-key (kbd "s-w") 'delete-window)
(global-set-key (kbd "s-b") 'helm-buffers-list)
(global-set-key (kbd "C-c C-/") 'comment-or-uncomment-region)
(global-set-key (kbd "s-/") 'comment-or-uncomment-region)

;; split management
(global-set-key (kbd "s-1") 'delete-other-windows)
(global-set-key (kbd "s-2") 'split-window-below)
(global-set-key (kbd "s-3") 'split-window-right)

;; only highlight after C-SPC C-SPC
(transient-mark-mode -1)

(require 'helm-config)

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
      (color-theme-cobalt)
      (set-face-attribute 'fringe nil :background "#092F4F")
      (set-face-attribute 'linum nil :background "#092F4F")))

(when (require 'yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

;; (global-linum-mode 0)

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

;; ;; ido settings (fuzzy finder)
;; (when (require 'ido)
;;   (ido-mode t)
;;   (setq ido-max-directory-size 10000
;;         Ido-enable-flex-matching t)) ;; enable fuzzy matching

;; auto-complete
(require 'auto-complete)
(require 'auto-complete-config)

;; enable autocomplete for other modes
(add-hook 'prog-mode-hook #'auto-complete-mode)

;; go-mode
(require 'go-mode-autoloads)
(require 'go-autocomplete)

;; multi cursors - starting to be better than sublime
(require 'multiple-cursors)
(global-set-key (kbd "C-.") 'mc/mark-next-like-this)
(global-set-key (kbd "C-,") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-,") 'mc/mark-all-like-this)

(set 'gofmt-command "goimports")

(defun partkyle-go-mode-hook ()
  (go-eldoc-setup)
  (add-hook 'before-save-hook 'gofmt-before-save)
  (setq-default tab-width 4)
  (setq-default indent-tabs-mode t)
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "C-c C-c") 'recompile))

(add-hook 'go-mode-hook 'partkyle-go-mode-hook)
