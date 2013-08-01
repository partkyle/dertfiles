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
 [f9]
 'jmc-eval-to-here)

(if (equal "xterm" (tty-type))
    (define-key input-decode-map "\e[1;2A" [S-up]))
(defadvice terminal-init-xterm (after select-shift-up activate)
  (define-key input-decode-map "\e[1;2A" [S-up]))

;; redo last command
(defun describe-last-function ()
  (interactive)
  (describe-function last-command))

;; color theme
(load-theme 'wombat)

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

;; look and feel
(if window-system
    (progn
      (set-frame-font "Inconsolata-g-14")
      (delete-selection-mode t)
      (tool-bar-mode -1)
      (blink-cursor-mode -1)
      (load-theme 'solarized-light t)))

(setq inhibit-startup-message t)
(show-paren-mode t)
(column-number-mode t)

;; line numbers don't have to be ugly
(defadvice linum-update-window (around linum-dynamic activate)
  (let* ((w (length (number-to-string
                     (count-lines (point-min) (point-max)))))
         (linum-format (concat "%" (number-to-string w) "d ")))
    ad-do-it))

(fset 'yes-or-no-p 'y-or-n-p)

(setq make-backup-files nil)
(setq auto-save-default nil)

;; tab settings
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; key bindings
(global-set-key (kbd "C-x g") 'grep)
(global-set-key (kbd "C-x C-g") 'grep)
(global-set-key (kbd "C-x C-o") 'other-window)
(global-set-key (kbd "C-S-k") 'kill-whole-line)

;; ido settings (fuzzy finder)
(when (require 'ido)
  (ido-mode t)
  (setq ido-max-directory-size 10000
        Ido-enable-flex-matching t)) ;; enable fuzzy matching

(defun ruby-mode-hook ()
  (autoload 'ruby-mode "ruby-mode" nil t)
  (add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Vagrantfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.ru\\'" . ruby-mode))
  (add-hook 'ruby-mode-hook '(lambda ()
                               (setq ruby-deep-arglist t)
                               (setq ruby-deep-indent-paren nil)
                               (setq c-tab-always-indent nil)
                               (require 'inf-ruby)
                               (require 'ruby-compilation))))

;; ruby-electric-mode for ruby scripts
(add-hook 'ruby-mode-hook
      (lambda ()
        (require 'ruby-electric)
        (ruby-electric-mode t)))
