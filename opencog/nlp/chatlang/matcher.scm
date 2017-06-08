;; ChatLang DSL for chat authoring rules
;;
;; This is the custom action selector that allows OpenPsi to find the authored
;; rules.
;; TODO: This is not needed in the long run as the default action selector in
;; OpenPsi should be able to know how and what kinds of rules it should be
;; looking for at a particular point in time.

(use-modules (opencog logger)
             (opencog exec))

(define-public (chat-find-rules SENT)
  "The action selector. It first searches for the rules using DualLink,
   and then does the filtering by evaluating the context of the rules.
   Eventually returns a list of weighted rules that can satisfy the demand"
  (let* ((input-lemmas (sent-get-lemmas-in-order SENT))
         (no-constant (append-map psi-get-exact-match
           (cog-chase-link 'InheritanceLink 'ListLink chatlang-no-constant)))
         (dual-match (psi-get-dual-match input-lemmas))
         (exact-match (psi-get-exact-match input-lemmas))
         (rules-matched (append dual-match exact-match no-constant)))
    (cog-logger-debug "For input:\n~aRules found:\n~a" input-lemmas rules-matched)

    ; TODO: Pick the one with the highest weight
    (List (append-map
      ; TODO: "psi-satisfiable?" doesn't work here (?)
      (lambda (r)
        (if (equal? (stv 1 1)
                    (cog-evaluate! (car (psi-get-context (gar r)))))
            (list (gar r))
            '()))
      rules-matched))))

(Define
  (DefinedSchema "Get Current Input")
  (Get (State chatlang-anchor
              (Variable "$x"))))

(Define
  (DefinedSchema "Find Chat Rules")
  (Lambda (VariableList (TypedVariable (Variable "sentence")
                                       (Type "SentenceNode")))
          (ExecutionOutput (GroundedSchema "scm: chat-find-rules")
                           (List (Variable "sentence")))))

; The action selector for OpenPsi
(psi-set-action-selector
  (Put (DefinedSchema "Find Chat Rules")
       (DefinedSchema "Get Current Input"))
  default-topic)
