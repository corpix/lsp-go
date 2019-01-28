;;; lsp-go.el --- Go support for lsp-mode

;; Copyright (C) 2017 Vibhav Pant <vibhavp@gmail.com>

;; Author: Vibhav Pant <vibhavp@gmail.com>
;; Version: 1.0
;; Package-Requires: ((lsp-mode "6.0"))
;; Keywords: go, golang
;; URL: https://github.com/emacs-lsp/lsp-go

(require 'lsp-mode)

(defgroup lsp-go nil
  "lsp-go settings"
  :group 'tools)

(defcustom lsp-go-executable-path (executable-find "go-langserver")
  "Path to the go-langserver executable."
  :type 'string
  :group 'lsp-go)

(defcustom lsp-go-language-server-flags '("-gocodecompletion")
  "Extra arguments for the go-langserver."
  :type '(repeat string)
  :group 'lsp-go)

(defcustom lsp-go-func-snippet-enabled t
  "Enable the returning of argument snippets on `func' completions, eg.
`func(foo string, arg2 bar)'.  Requires code completion to be enabled."
  :type 'bool
  :group 'lsp-go)

(defcustom lsp-go-gocode-completion-enabled t
  "Enable code completion feature (using gocode)."
  :type 'bool
  :group 'lsp-go)

(defcustom lsp-go-format-tool "goimports"
  "The tool to be used for formatting documents.  Defaults to `goimports' if nil."
  :type '(choice (const :tag "goimports" "goimports")
                 (const :tag "gofmt" "gofmt"))
  :group 'lsp-go)

(defcustom lsp-go-imports-local-prefix ""
  "The local prefix (comma-separated string) that goimports will use."
  :type 'string
  :group 'lsp-go)

(defcustom lsp-go-max-parallelism nil
  "The maximum number of goroutines that should be used to fulfill requests.
This is useful in editor environments where users do not want results ASAP,
but rather just semi quickly without eating all of their CPU.  When nil,
defaults to half of your CPU cores."
  :type '(choice integer (const nil "Half of CPU cores."))
  :group 'lsp-go)

(defcustom lsp-go-use-binary-pkg-cache t
  "Whether or not $GOPATH/pkg binary .a files should be used."
  :type 'bool
  :group 'lsp-go)

(define-inline lsp-go--bool-to-json (val)
  (inline-quote (if ,val t :json-false)))

(defun lsp-go--make-init-options ()
  `(:funcSnippetEnabled ,(lsp-go--bool-to-json lsp-go-func-snippet-enabled)
                        :gocodeCompletionEnabled ,(lsp-go--bool-to-json lsp-go-gocode-completion-enabled)
                        :formatTool ,lsp-go-format-tool
                        :goimportsLocalPrefix ,lsp-go-imports-local-prefix
                        :maxParallelism ,lsp-go-max-parallelism
                        :useBinaryPkgCache ,lsp-go-use-binary-pkg-cache))

(defun lsp-go--ls-command ()
  "LS startup command."
  `(,lsp-go-executable-path "-mode=stdio" ,@lsp-go-language-server-flags))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection 'lsp-go--ls-command)
  :major-modes '(go-mode)
  :server-id 'go-langserver
  :ignore-regexps '("^langserver-go: reading on stdin, writing on stdout$")
  :initialization-options #'lsp-go--make-init-options))

(provide 'lsp-go)
;;; lsp-go.el ends here
