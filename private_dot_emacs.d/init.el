;; -*- lexical-binding: t -*-

(when (file-exists-p "~/.emacs.d/secrets.el")
  (load "~/.emacs.d/secrets.el"))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(straight-use-package 'org)

(use-package straight
:custom
;; add project and flymake to the pseudo-packages variable so straight.el doesn't download a separate version than what eglot downloads.
(straight-built-in-pseudo-packages '(emacs nadvice python eglot image-mode project flymake)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(undecorated . t))

(set-face-attribute 'default nil :family "VictorMono Nerd Font" :height 110)
(set-face-attribute 'fixed-pitch nil :family "VictorMono Nerd Font" :height 110)
(set-face-attribute 'variable-pitch nil :family "Fira Sans" :height 125 :weight 'regular)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(dolist (mode '(org-mode-hook
                org-agenda-mode-hook
                term-mode-hook
                vterm-mode-hook
                eat-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq-default cursor-type 'bar)

(setq scroll-conservatively 50)
(setq scroll-margin 15)
(setq frame-resize-pixelwise t)

(setq scroll-preserve-screen-position nil)
(setq scroll-step 1)

(setq-default indent-tabs-mode nil)

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package dired
  :straight nil
  :custom ((dired-listing-switches "-agho --group-directories-first")))
(use-package dired-single)
(use-package diredfl
  :hook (dired-mode . diredfl-mode))
(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(defun ars/kill-buffer-and-window-or-frame ()
  (interactive)
  (kill-buffer (current-buffer))
  (if (eq (count-windows) 1)
      (delete-frame)
    (delete-window)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; (use-package evil-commentary
;;   :after evil
  ;; :config (evil-commentary-mode))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package general
  :config
  (general-create-definer my-leader-def
    :prefix "SPC"
    :keymaps 'override)

  (my-leader-def
    :states '(normal visual motion)
    "f" '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "fs" '(save-buffer :which-key "save file")
    "fd" '(dired :which-key "dired")
    "e" '(:ignore t :which-key "eshell/evaluate")
    "en" '(ars/create-eshell :which-key "create new eshell")
    "eh" '(eshell-syntax-highlighting-mode :which-key "toggle syntax highlighting")
    "ec" '(ars/fix-remote-dockers :which-key "clear tramp proxies list")
    "ee" '(eval-region :which-key "eval region (emacs lisp)")
    "c" '(:ignore t :which-key "consult")
    "co" '(consult-outline :which-key "outline")
    "cg" '(consult-git-grep :which-key "grep")
    "cr" '(consult-ripgrep :which-key "ripgrep")
    "ci" '(consult-imenu :which-key "imenu")
    "ch" '(consult-history :which-key "history")
    "s" '(consult-line :which-key "search")
    "o" '(:ignore t :which-key "org")
    "oa" '(org-agenda :which-key "agenda")
    "of" '(org-open-at-point :which-key "follow link")
    "oi" '(org-id-get-create :which-key "create id")
    "ob" '(org-mark-ring-goto :which-key "return back")
    "oc" '(org-capture :which-key "capture")
    "oq" '(org-ql-find-in-org-directory :which-key "query")
    "ot" '(org-timestamp :which-key "insert date")
    "on" '(:ignore t :which-key "org-node")
    "onr" '(org-node-refile :which-key "org-node refile")
    "onf" '(org-node-find :which-key "find node")
    "oni" '(org-node-insert-link :which-key "insert link")
    "one" '(org-node-extract-subtree :which-key "extract to new file")
    "u" '(universal-argument :which-key "universal argument")
    "w" 'evil-window-map
    "p" project-prefix-map
    "h" help-map
    "." '(evil-avy-goto-char :which-key "avy goto char 2")
    "g" '(magit-status :which-key "magit")
    "t" '(:ignore t :which-key "lsp")
    "tr" '(eglot-rename :which-key "rename")
    "ta" '(eglot-code-actions :which-key "actions")
    "tt" '(eldoc-box-help-at-point :which-key "find definition")
    "l" '(:ignore t :which-key "LLM")
    "ln" '(gptel :which-key "gptel")
    "ls" '(gptel-send :which-key "send prompt")
    "lm" '(gptel-menu :which-key "menu")
    "la" '(aider-transient-menu :which-key "aider")
    "b" '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")
    "be" '(ars/kill-buffer-and-window-or-frame :which-key "kill buffer and window/frame")
    "bk" '(kill-buffer :which-key "kill buffer")))

(use-package meow
  :config
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))
  (meow-setup))

(use-package emacs
  :init
  (setq tab-always-indent 'complete)
  (setq warning-minimum-level :error)
  (setq vc-follow-symlinks nil)
  (setq native-comp-deferred-compilation t)
  (setq make-backup-files nil)
  (setq eat-term-name "xterm-256color")
  (setq split-height-threshold nil)
  (setq split-width-threshold 80)
  (setq help-window-select t)
  (setq redisplay-dont-pause t)
  (setq tags-completion-at-point-function nil)
  
  (global-auto-revert-mode 1)
  (setq auto-revert-remote-files t))
(use-package gcmh
  :config (gcmh-mode 1))

(use-package tramp
  :straight nil
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq remote-file-name-inhibit-locks t)
  (setq tramp-allow-unsafe-temporary-files t)
  (setq tramp-verbose 6)
  (setq tramp-show-ad-hoc-proxies t)
  (setq tramp-save-ad-hoc-proxies nil))

(defun ars/fix-remote-dockers ()
  (interactive)
  (setq tramp-default-proxies-alist nil))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-max-description-length 50)
  (setq which-key-idle-delay 1))

(use-package nerd-icons)
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-lsp-icon t)
  (setq doom-modeline-lsp t))


(custom-set-faces
 '(flymake-error ((t (:underline (:style line :color "red")))))
 '(flymake-warning ((t (:underline (:style line :color "yellow")))))
 '(flymake-note ((t (:underline (:style line :color "green"))))))

(set-frame-parameter nil 'alpha-background 93)
(add-to-list 'default-frame-alist '(alpha-background . 93))
(add-to-list 'default-frame-alist '(undecorated t))
(setq split-height-threshold 1000)

(use-package catppuccin-theme
  :config
  (load-theme 'catppuccin :no-confirm)
  (setq catppuccin-flavor 'mocha) ;; or 'latte, 'macchiato, or 'mocha
  (catppuccin-reload))

;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   (setq doom-themes-enable-bold t
;;         doom-themes-enable-italic nil)
;;   (load-theme 'doom-dracula t)

;;   (doom-themes-visual-bell-config)
;;   (doom-themes-org-config))

(setq ring-bell-function 'ignore)

(use-package avy
  :config
  (avy-setup-default))

(use-package vertico
  :init
  (vertico-mode)
  (setq vertico-cycle t))

(use-package savehist
  :init
  (savehist-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package tree-sitter
  :hook
  (python-mode . tree-sitter-hl-mode)
  (javascript-mode . tree-sitter-hl-mode)
  (dockerfile-mode . tree-sitter-hl-mode)
  (rust-mode . tree-sitter-hl-mode)
  (lua-mode . tree-sitter-hl-mode)
  (sh-mode . tree-sitter-hl-mode)
  :config
  (global-tree-sitter-mode))
(use-package tree-sitter-langs)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-indent-guides
  :hook
  (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-auto-character-face-perc 80)
  (highlight-indent-guides-method 'character))

(use-package autopair
  :hook
  (prog-mode . autopair-mode))

(use-package breadcrumb
  :init
  (breadcrumb-mode))

(use-package project
  :straight nil
  :config
  (setq compilation-scroll-output t))

(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '(web-mode "vls"))
  (setq-default
     eglot-workspace-configuration
     '(:basedpyright (
         :typeCheckingMode "basic"
       )
       :python (
         :pythonPath "/usr/local/bin/python3"
       )
       ))

  :hook
  ((python-mode) . eglot-ensure))

(use-package eldoc-box)

(use-package eglot-booster
  :straight (eglot-booster :type git :host github :repo "jdtsmith/eglot-booster")
  :after eglot
  :config (eglot-booster-mode))

;; (use-package lsp-mode
;;   ;; :hook (python-mode . lsp-deferred)
;;   :commands lsp
;;   :config
;;   (setq lsp-enable-file-watchers nil
;;         lsp-headerline-breadcrumb-enable t
;;         lsp-headerline-breadcrumb-enable-diagnostics nil
;;   	lsp-inlay-hint-enable t
;; 	lsp-pylsp-plugins-rope-autoimport-enabled t
;;         lsp-pylsp-plugins-rope-completion-enabled t
;;         lsp-pylsp-plugins-rope-autoimport-completions-enabled t
;;         lsp-pylsp-plugins-rope-autoimport-code-actions-enabled t
;; 	lsp-pylsp-plugins-ruff-enabled t
;; 	lsp-pylsp-plugins-flake8-enabled nil
;; 	lsp-pylsp-plugins-pycodestyle-enabled nil
;; 	lsp-pylsp-plugins-mccabe-enabled nil
;; 	lsp-pylsp-plugins-autopep8-enabled nil
;; 	lsp-pylsp-plugins-yapf-enabled nil
;; 	lsp-pylsp-plugins-ruff-ignore '("D100")
;; 	lsp-pylsp-plugins-mypy-enabled t
;; 	lsp-pylsp-plugins-mypy-strict t
;; 	lsp-disabled-clients '(lsp-ruff ruff ruff-tramp)
;;         lsp-modeline-diagnostics-enable nil)
;;   :custom
;;   (lsp-pyright-multi-root nil)
;;   (lsp-pyright-typechecking-mode "basic"))

;; (use-package lsp-pyright
;;   :custom (lsp-pyright-langserver-command "basedpyright") ;; or basedpyright
;;   :hook (python-mode . (lambda ()
;;                          (require 'lsp-pyright)
;;                          (lsp-deferred))))

;; (use-package lsp-ui
;;   :custom
;;   (lsp-ui-sideline-enable nil)
;;   (lsp-ui-doc-delay 1)
;;   (lsp-ui-doc-side 'left)
;;   (lsp-ui-doc-position 'at-point)
;;   (lsp-ui-doc-show-with-cursor t))

(use-package flycheck
   :config
   (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package web-mode
  :hook
  (web-mode . eglot-ensure)
  :mode "\\.vue\\'")
(use-package dockerfile-mode)
(use-package docker-compose-mode)
(use-package zig-mode)
(use-package lua-mode)
(use-package rust-mode)
(use-package kdl-mode)
(use-package hyprlang-ts-mode
  :mode "^hypr.*\\.conf$")

(use-package corfu
  :hook ((prog-mode . corfu-mode)
       (shell-mode . corfu-mode)
       (eshell-mode . corfu-mode))
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  (corfu-auto-prefix 2)
  (corfu-popupinfo-mode))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package magit
  :after evil-collection
  :config
  (setq magit-auto-revert-mode t)
  (evil-collection-define-key 'normal 'magit-mode-map
    (kbd "SPC") nil
    "j" 'magit-section-forward
    "k" 'magit-section-backward
    "C-j" 'evil-next-visual-line
    "C-k" 'evil-previous-visual-line))

(use-package aider
  ;; :straight
  ;; (:host github :repo "tninja/aider.el" :files ("aider.el" "aider-core.el" "aider-file.el" "aider-code-change.el" "aider-discussion.el" "aider-prompt-mode.el" "aider-agile.el" "aider-code-read.el" "aider-legacy-code.el"))
  :config
   (setq aider-args `(;;"--model" "lm_studio/bartowski/qwen_qwq-32b"
	             ;; "--model" "lm_studio/bartowski/mistralai_Mistral-Small-3.1-24B-Instruct-2503-GGUF"
		     ;; "--model" "lm_studio/bartowski/deepcogito_cogito-v1-preview-qwen-32B-GGUF"
		     ;; "--model" "lm_studio/bartowski/THUDM_GLM-4-32B-0414-GGUF"
		     ;; "--model" "lm_studio/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF"
		     ;; "--model" "lm_studio/unsloth/qwen3-30b-a3b"
		     ;; "--model" "lm_studio/unsloth/qwen3-30b-a3b-instruct-2507"
		     "--model" "lm_studio/unsloth/qwen3-coder-30b-a3b-instruct"
		     ;; "--model" "lm_studio/unsloth/qwen3-14b"
		     ;; "--model" "lm_studio/unsloth/qwen3-32b"
                     ;; "--model" "anthropic/claude-3-7-sonnet-20250219"
		     ;; "--anthropic-api-key" ,ANTHROPIC_KEY
	             "--no-auto-commits"
	             "--no-show-model-warnings"
                     "--map-tokens" "0")))
;; (setq aider-args `("--model" "codestral/codestral-latest" "--api-key" ,(format "CODESTRAL=%s" CODESTRAL_KEY) "--no-auto-commits" "--subtree-only")))
 ;; (setq aider-args `("--model" "anthropic/claude-3-7-sonnet-20250219" "--anthropic-api-key" ,ANTHROPIC_KEY "--no-auto-commits" "--watch-files" "--map-tokens" "0")))

(use-package minuet
  :straight (minuet :host github :repo "milanglacier/minuet-ai.el") 
  :bind
  (("M-i" . #'minuet-show-suggestion)

   :map minuet-active-mode-map
   ("M-p" . #'minuet-previous-suggestion)
   ("M-n" . #'minuet-next-suggestion)
   ("M-<tab>" . #'minuet-accept-suggestion)
   ("M-TAB" . #'minuet-accept-suggestion)
   ;; Accept the first line of completion, or N lines with a numeric-prefix:
   ;; e.g. C-u 2 M-a will accepts 2 lines of completion.
   ("C-TAB" . #'minuet-accept-suggestion-line)
   ("C-<tab>" . #'minuet-accept-suggestion-line)
   ("M-e" . #'minuet-dismiss-suggestion))

  :hook
  ;; (prog-mode . minuet-auto-suggestion-mode)
  (minuet-active-mode-hook . evil-normalize-keymaps)

  :config
  (setq minuet-provider 'openai-compatible)
  (setq minuet-context-window 4000)
  (setq minuet-n-completions 1)
  ;;     (setq minuet-default-guidelines
  ;; "/nothink Guidelines:
  ;; 1. Offer completions after the `<cursorPosition>` marker.
  ;; 2. Make sure you have maintained the user's existing whitespace and indentation.
  ;;    This is REALLY IMPORTANT!
  ;; 3. Provide multiple completion options when possible.
  ;; 4. Return completions separated by the marker <endCompletion>.
  ;; 5. The returned message will be further parsed and processed. DO NOT include
  ;;    additional comments or markdown code block fences. Return the result directly.
  ;; 6. Keep each completion option concise, limiting it to a single line.
  ;;    Never add new lines, only complete line where user's cursor is at the moment.
  ;; 7. Create entirely new code completion that DO NOT REPEAT OR COPY any user's existing code around <cursorPosition>.")
  (plist-put minuet-openai-compatible-options :end-point "http://localhost:8080/v1/completions")
  ;; an arbitrary non-null environment variable as placeholder
  (plist-put minuet-openai-compatible-options :name "Llama.cpp")
  (plist-put minuet-openai-compatible-options :api-key "TERM")
  ;; The model is set by the llama-cpp server and cannot be altered
  ;; post-launch.
  (plist-put minuet-openai-compatible-options :model "PLACEHOLDER")

  ;; Llama.cpp does not support the `suffix` option in FIM completion.
  ;; Therefore, we must disable it and manually populate the special
  ;; tokens required for FIM completion.
  (minuet-set-nested-plist minuet-openai-fim-compatible-options nil :template :suffix)
  (minuet-set-optional-options
   minuet-openai-fim-compatible-options
   :prompt
   (defun minuet-llama-cpp-fim-qwen-prompt-function (ctx)
     (format "<|fim_prefix|>%s\n%s<|fim_suffix|>%s<|fim_middle|>"
             (plist-get ctx :language-and-tab)
             (plist-get ctx :before-cursor)
             (plist-get ctx :after-cursor)))
   :template)

  (minuet-set-optional-options minuet-openai-fim-compatible-options :max_tokens 56))

;; Example configuration for Consult
(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"
  (setq consult-preview-excluded-files '("\\.gpg\\'"))
  )

(use-package eat
  :config
  (setq eat-enable-yank-to-terminal t)
  (eat-eshell-mode))

(use-package eshell
  :ensure nil
  :hook ((eshell-mode . (lambda ()
			  (setenv "PATH" (concat "/home/linuxbrew/.linuxbrew/bin:" (getenv "PATH")))
                          (setq-local corfu-count 7)
                          (setq-local corfu-auto nil)
                          (setq-local corfu-preview-current nil))))
                          ;; (setq-local completion-at-point-functions '(pcomplete-completions-at-point cape-file)))))
  :custom
  (eshell-history-size 1024)
  (eshell-pushd-dunique t)
  (eshell-last-dir-unique t)
  (eshell-last-dir-ring-size 128)
  (eshell-scroll-to-bottom-on-input t)
  :config
  (setq eshell-visual-commands nil)
  :init
  (add-to-list 'exec-path "/home/templarrr/.local/bin")
  (add-to-list 'exec-path "/home/linuxbrew/.linuxbrew/bin")
  (defun eshell/cat-with-syntax-highlighting (filename)
    "Like cat(1) but with syntax highlighting.
Stole from aweshell"
    (let ((existing-buffer (get-file-buffer filename))
          (buffer (find-file-noselect filename)))
      (eshell-print
       (with-current-buffer buffer
         (if (fboundp 'font-lock-ensure)
             (font-lock-ensure)
           (with-no-warnings
             (font-lock-fontify-buffer)))
         (let ((contents (buffer-string)))
           (remove-text-properties 0 (length contents) '(read-only nil) contents)
           contents)))
      (unless existing-buffer
        (kill-buffer buffer))
      nil))
  (advice-add 'eshell/cat :override #'eshell/cat-with-syntax-highlighting))



(use-package eshell-syntax-highlighting
  :ensure t
  :config
  (eshell-syntax-highlighting-global-mode +1)
  (setq eshell-syntax-highlighting-highlight-in-remote-dirs t))

(use-package eshell-up)

(defun ars/get-new-eshell-name ()
  (if (get-buffer "*host eshell*")
  "*unnamed eshell*"
  "*host eshell*"))

(defun ars/create-eshell (&optional create-new-frame)
  "creates a shell with a given name or swithes to it if it already exists"
  (interactive)
  (let* ((create-new-frame (and create-new-frame t))
	   (buffer-name (ars/get-new-eshell-name)))
    (if (get-buffer buffer-name)
	  (switch-to-buffer buffer-name)
	  (let ((frame (if (not create-new-frame) (selected-frame) (make-frame))))
		(progn
		(select-frame-set-input-focus frame)
		(eshell)
		(rename-buffer buffer-name))))))

(use-package eshell-prompt-extras
  :config
  (setq eshell-highlight-prompt nil
        epe-show-git-status-extended t
        epe-path-style 'full
	eshell-prompt-function 'epe-theme-multiline-with-status))
        ;; eshell-prompt-function (lambda () (propertize (epe-theme-multiline-with-status)
        ;;                                    'read-only t
	;; 				   'font-face-lock 'eshell-prompt
	;; 				   'field nil
	;; 				   'front-sticky t
        ;;                                    'rear-nonsticky t))))

(use-package esh-autosuggest
  :hook (eshell-mode . esh-autosuggest-mode))

(defun eshell/shallow-research ()
  (eshell/cd "~/Development/shallow-research/")
  (if (string= "" (shell-command-to-string "docker compose -f docker-compose-dev.yml ps | grep Up"))
     (shell-command-to-string "docker compose -f docker-compose-dev.yml up -d --build"))
  (eshell/cd "/docker:shallow_research_dev:/home/shallow-research/shallow-research/")
  (rename-buffer "*shallow-research eshell*"))

(defun eshell/piiq-local ()
  (eshell/cd "~/Development/piiq-dev-containers")
  (if (string= "" (shell-command-to-string "docker compose ps | grep Up"))
     (shell-command-to-string "docker compose up -d --build"))
  (eshell/cd "/docker:piiq:/home/piiq/piiq-media/")
  (rename-buffer "*piiq local eshell*"))

(defun eshell/piiq-worker2-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-worker2:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq worker2 eshell*"))

(defun eshell/piiq-worker4-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-worker2|docker:worker-worker-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq worker2 eshell*"))

(defun eshell/piiq-worker3-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-worker3:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq worker2 eshell*"))

(defun eshell/piiq-worker3-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-worker3|docker:worker-worker-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq worker3 eshell*"))

(defun eshell/piiq-worker4-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-worker4:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq worker4 eshell*"))

(defun eshell/piiq-worker4-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-worker4|docker:worker-worker-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq worker4 eshell*"))

(defun eshell/piiq-cron-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-cron:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq cron eshell*"))

(defun eshell/piiq-cron-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-cron|docker:cronserver-cronserver-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq cron eshell*"))

(defun eshell/piiq-mongosync-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-mongosync:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq mongosync eshell*"))

(defun eshell/piiq-mongosync-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-mongosync|docker:mongosync-mongosync-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq mongosync eshell*"))

(defun eshell/piiq-stage-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-stage:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq stage eshell*"))

(defun eshell/piiq-stage-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-stage|docker:worker-worker-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq stage eshell*"))

(defun eshell/piiq-stage-mongo-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-stage-mongo:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq stage eshell*"))

(defun eshell/piiq-stage-mongo-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-stage-mongo|docker:sharded-mongodb-docker-mongos-router0-1:/")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq stage eshell*"))

(defun eshell/piiq-dev5-host ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-dev5:/opt/piiq/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq dev5 eshell*"))

(defun eshell/piiq-dev5-docker ()
  (ars/fix-remote-dockers)
  (eshell/cd "/ssh:piiq-dev5|docker:worker-worker-1:/opt/piiq-media")
  (eshell-syntax-highlighting-mode -1)
  (rename-buffer "*piiq dev5 eshell*"))

(defun eshell/piiq-restart-containers ()
  (if (file-exists-p "./app/manage.py")
      (progn
        (eshell/cd "./sys/worker/")
        (shell-command "docker compose restart")
        (eshell/cd "../webserver/")
        (shell-command "docker compose restart")
        (eshell/cd "../mongosync")
        (shell-command "docker compose restart")
        (eshell/cd "../cronserver")
        (shell-command "docker compose restart")
      (eshell/cd "../../"))
    (eshell/echo "Current directory is not a piiq project root")))

(use-package gptel
    :config
    (setq
     ;; gptel--system-message "You are Mistral Small 3, a Large Language Model (LLM) created by Mistral AI, a French startup headquartered in Paris.
;; Your knowledge base was last updated on 2023-10-01. The current date is 2025-01-30.
;; When you're not sure about some information, you say that you don't have the information and don't make up anything.
;; If the user's question is not clear, ambiguous, or does not provide enough context for you to accurately answer the question, you do not try to answer it right away and you rather ask the user to clarify their request (e.g. \"What are some good restaurants around me?\" => \"Where are you?\" or \"When is the next flight to Tokyo\" => \"Where do you travel from?\")"
     gptel-temperature 0.15
     gptel-model 'llamacpp
     gttel--system-message "Enable deep thinking subroutine"
     gptel-backend (gptel-make-openai "llama-cpp"          ;Any name
                     :stream t                             ;Stream responses
                     :protocol "http"
                     :host "localhost:8081"                ;Llama.cpp server location
                     :models '(llamacpp))
     gptel-default-mode 'org-mode))
  ;; (setq gptel-api-key OPENAI_KEY)
  ;; (setq gptel-model "gpt-4o"))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.4)
                  (org-level-2 . 1.3)
                  (org-level-3 . 1.2)
                  (org-level-4 . 1.1)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Fira Sans" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 150
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package org
  :after evil
  :hook
  (org-mode . efs/org-mode-setup)
  ;; (org-mode . (lambda () (company-mode -1)))
  :config
  (setq org-ellipsis " ▾")
  (setq org-refile-targets '((nil . (:maxlevel 4))))
  (setq org-goto-interface 'outline-path-completion)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-goto-max-level 4)
  (setq org-refile-use-outline-path t)
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-files (flatten-list
                          (list (directory-files-recursively "~/Documents/Org/Tasks/" "\\.org$")
                                (directory-files-recursively "~/Documents/Org/Development/" "\\.org$"))))
  (setq org-agenda-align-tags-to-column 90)
  (setq org-agenda-prefix-format
      '((agenda . " %i %?-12t% s")
        (todo . " %i")
        (tags . " %i")
        (search . " %i")))
  (setq org-directory "~/Documents/Org")
  (setq org-link-frame-setup
      '((file . find-file)))

  (efs/org-font-setup)
  (require 'org-tempo)
  :bind
  (("C-c c" . org-capture)
   ("C-c a" . org-agenda)))

(use-package visual-fill-column
  :hook
  (org-mode . efs/org-mode-visual-fill))

(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq org-pretty-entities t)
  (setq org-modern-fold-stars
	'(("◉" . "◉")
	  ("○" . "○")
	  ("●" . "●")
	  ("○" . "○")
	  ("●" . "●")
	  ("○" . "○")
	  ("●" . "●")))
  (setq org-modern-checkbox
	'((88 . "󰱒")
	  (45 . "󱋭")
	  (32 . "󰄱"))))

(defun my-prompt-knowledge-areas ()
  (let* ((base-dir "~/Documents/Org/")
         (subdirs (mapcar 'file-name-nondirectory
                          (seq-filter 'file-directory-p
                                      (directory-files base-dir t "^[^.]" t))))
         (selection (completing-read "Choose a knowledge area: " subdirs nil nil)))
    (let ((full-path (expand-file-name selection base-dir)))
      (unless (file-directory-p full-path)
        (make-directory full-path))
      full-path)))

(defun my-prompt-knowledge-subjects (directory)
  (let* ((files (seq-filter
                 (lambda (file)
                   (and (file-regular-p file)
                        (string-equal (file-name-extension file) "org")))
                 (directory-files directory t "^[^.]" t)))
         (file-names (mapcar (lambda (file)
                               (file-name-sans-extension (file-name-nondirectory file)))
                             files))
         (selection (completing-read "Choose a subject: " file-names nil nil)))
    (let ((full-path (expand-file-name (concat selection ".org") directory)))
      (unless (file-exists-p full-path)
        (write-region "" nil full-path))
      full-path)))

(defun my-org-goto-or-insert ()
  (if (save-excursion
        (goto-char (point-min))
        (re-search-forward org-heading-regexp nil t))
      (org-goto)
    (goto-char (point-min))))

(setq org-capture-templates
      '(("j" "Journal entry")
        ("jm" "Meeting"
         entry (file+olp+datetree "~/Documents/Org/Journal/meetings.org")
         "* %?"
         :empty-lines 0)
        ("jt" "Typing"
         entry (file+olp+datetree "~/Documents/Org/Journal/typing-progress.org")
         "* %?"
         :empty-lines 0)
        ("k" "Knowledge entry")
        ("ka" "Add subheading"
         entry (file+function (lambda () (my-prompt-knowledge-subjects (my-prompt-knowledge-areas))) my-org-goto-or-insert)
         "* %?"
         :empty-lines 1)
        ("kn" "New top level heading"
         entry (file (lambda () (my-prompt-knowledge-subjects (my-prompt-knowledge-areas))))
         "* %?"
         :empty-lines 0)))

(org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
    (python . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

(defun efs/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/Documents/Org/Emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package org-ql
  :bind
  ("C-c q" . org-ql-find-in-org-directory))

(use-package org-node
  :after org
  :config
  (setq org-node--untitled-ctr 0)
  (setq org-mem-do-sync-with-org-id t)
  (org-mem-updater-mode)
  (org-node-cache-mode)
  (org-node-backlink-mode)
  (setq org-node-ask-directory t)
  (setq org-node-extra-id-dirs
    '("~/Documents/Org/"))
  (setq org-node-backlink-aggressive t))

;; (use-package git-auto-commit-mode
;;   :init
;;   (setq gac-automatically-push-p t))

(provide '.emacs)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
