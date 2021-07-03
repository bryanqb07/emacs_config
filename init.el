(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10) ;breathing room
(menu-bar-mode -1) ;disable menu bar
(set-face-attribute 'default nil :font "Fira Mono" :height 180) ;set default font
(load-theme 'tango-dark)
(setq default-font-size 280)

;; Increase for better lsp-mode performance; see
;; https://emacs-lsp.github.io/lsp-mode/page/performance/
(setq gc-cons-threshold 100000000)
(when (boundp 'read-process-output-max)
  ;; New in Emacs 27
  (setq read-process-output-max (* 1024 1024)))


;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

; line numbers
(column-number-mode)
(global-display-line-numbers-mode)
; disable line numbers for certain modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode))

; fix the $PATH variable in the emulated shell
(use-package exec-path-from-shell
  :init (when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package all-the-icons)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))


;similar to vim airplane
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package doom-themes
  :init (load-theme 'doom-palenight t))

;helpful list of key shortcuts
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package counsel
  :demand t
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ;; ("C-M-j" . counsel-switch-buffer)
         ("C-M-l" . counsel-imenu)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^


(use-package ivy-rich
  :init (ivy-rich-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

(use-package general
  :config
  (general-create-definer bml/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (bml/leader-keys
   "t" '(:ignore "t" :which-key "toggles")
   "tt" '(counsel-load-theme :which-key "choose theme")))

(defun bml/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  circe-server-mode
                  circe-chat-mode
                  circe-query-mode
                  sauron-mode
                  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))


(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-tree)
  :config
  (add-hook 'evil-mode-hook 'bml/evil-hook)
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(bml/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :demand t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; (when (file-directory-p "~/Developer")
  ;;   (setq projectile-project-search-path '("~/Developer"))
  ;;   (setq projectile-project-search-path '("~/Developer/clojure"))
  ;;   (setq projectile-switch-project-action #'projectile-dired))


  (when (file-directory-p "~/Work")
    (setq projectile-project-search-path '("~/Work"))
    (setq projectile-switch-project-action #'projectile-dired)))


(use-package counsel-projectile
  :after projectile
  :bind (("C-M-p" . counsel-projectile-find-file))
  :config
  (counsel-projectile-mode))

(bml/leader-keys
  "pf"  'counsel-projectile-find-file
  "ps"  'counsel-projectile-switch-project
  "pF"  'counsel-projectile-rg
  "pp"  'counsel-projectile
  "pc"  'projectile-compile-project
  "pd"  'projectile-dired)

(global-set-key (kbd "s-f") 'counsel-projectile-find-file)
(global-set-key (kbd "s-p") 'counsel-projectile-rg)

(use-package magit
;  :bind ("C-M-;" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
;  :diminish (lsp-mode . "LSP")
  :init (setq lsp-key-map-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))
  ;; :bind (:map lsp-mode-map
  ;;             ("C-c l" . #'lsp-execute-code-action))
  ;; :custom
  ;; (lsp-file-watch-threshold nil)
  ;; (lsp-solargraph-multi-root nil)
  ;; :config
  ;; (defun amk-lsp-format-buffer-quick ()
  ;;   (let ((lsp-response-timeout 2))
  ;;     (lsp-format-buffer)))
  ;; (defun amk-lsp-format-on-save ()
  ;;   (add-hook 'before-save-hook #'amk-lsp-format-buffer-quick nil t))
  ;; (defun amk-lsp-disable-format-on-save ()
  ;;   (remove-hook 'before-save-hook #'amk-lsp-format-buffer-quick t))
  ;; (defun amk-lsp-organize-imports-on-save ()
  ;;   (add-hook 'before-save-hook #'lsp-organize-imports nil t)))

(use-package ruby-mode
  :ensure nil
  :after lsp-mode)

;(add-hook 'ruby-mode-hook 'lsp-deferred) ; ruby hooks not working on use-package so i define it here
(add-hook 'c-mode-hook 'lsp)

(use-package inf-ruby)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
	      ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
	("<tab>" . company-indent-or-complete-common))
  
  :custom (company-idle-delay 0.3))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package paredit)

(use-package clojure-mode)

(use-package clojure-mode-extra-font-locking)

(use-package cider)

(use-package dumb-jump
  :config (setq dumb-jump-selector 'ivy))
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

(add-to-list 'load-path "~/.emacs.d/customizations")

(load "setup-clojure.el")

(use-package flymake)
(use-package flymake-ruby)
(add-hook 'ruby-mode-hook 'flymake-ruby-load)
(setq ruby-insert-encoding-magic-comment nil)
(use-package git-gutter)
(global-git-gutter-mode +1)

(use-package neotree)
(global-set-key [f8] 'neotree-toggle)

(defun find-or-open-split-terminal ()
  (interactive)
  (split-window-right)
  (select-window (next-window))
  (if (get-buffer "*terminal*")
      (switch-to-buffer "*terminal*") 
      (call-interactively 'term)))

(global-set-key (kbd "s-t") 'find-or-open-split-terminal)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ivy-rich-mode t)
 '(package-selected-packages
   '(neotree git-gutter flymake-ruby fly-make-ruby dumb-jump projectile-rails robe company-lsp undo-tree lsp-ui company-box company company-mode lsp-mode evil-magit magit exec-path-from-shell ripgrep counsel-projectile projectile hydra evil-collection evil general doom-themes helpful counsel ivy-rich which-key rainbow-delimiters doom-modeline ivy command-log-mode use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
