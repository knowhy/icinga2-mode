;;; icinga2-mode.el --- major mode for editing icinga2 configuration files

;; Copyright (C) 2013 Henrik Pingel

;; Author: Henrik Pingel <knowhy@gmail.com>
;; URL: http://github.com/knowhy/icinga2-mode
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


(defgroup icinga2-mode nil
  "Icinga2 mode."
  :group 'comm)

(defvar icinga2-mode-hook nil)

;; syntax highlighting

(setq icinga2-attribute-keywords '("display_name" "check" "groups" "host_dependencies" "service_dependencies" "services" "macros" "host" "short_name" "display_name" "macros" "check_command" "templates" "template" "max_check_attempts" "check_period" "check_interval" "retry_interval" "enable_notifications" "enable_active_checks" "enable_passive_checks" "enable_event_handler" "enable_flap_detection" "enable_perfdata" "event_command" "flapping_threshold" "volatile" "groups" "notifications" "times" "users" "user_groups" "notification_command" "notification_interval" "notification_period" "notification_type_filter" "notification_state_filter" "methods" "ranges" "severity" "path" "export_macros" "escape_macros" "timeout" "perfdata_path" "temp_path" "format_template" "rotation_interval" "host" "port" "user" "password" "database" "table_prefix" "instance_name" "instance_description" "cleanup" "categories"  "instance_name" "instance_description" "cleanup" "categories" "socket_type" "bind_host" "bind_port" "socket_path" "compat_log_path" "status_path" "objects_path" "command_path" "log_dir" "rotation_method" "spool_dir" "cert_path" "key_path" "ca_path" "crl_path" "peers" "node" "service" "config_files" "accept_config" "acl"))

(setq icinga2-cleanup-items-keywords '("acknowledgements_age" "commenthistory_age" "contactnotifications_age" "contactnotificationmethods_age" "downtimehistory_age" "eventhandlers_age" "externalcommands_age" "flappinghistory_age" "hostchecks_age" "logentries_age" "notifications_age" "processevents_age" "statehistory_age" "servicechecks_age" "systemcommands_age" "acknowledgements_age" "commenthistory_age" "contactnotifications_age" "contactnotificationmethods_age" "downtimehistory_age" "eventhandlers_age" "externalcommands_age" "flappinghistory_age" "hostchecks_age" "logentries_age" "notifications_age" "processevents_age" "statehistory_age" "statehistory_age" "systemcommands_age"))

(setq icinga2-category-keywords '("DbCatConfig" "DbCatState" "DbCatAcknowledgement" "DbCatAcknowledgement" "DbCatDowntime" "DbCatEventHandler" "DbCatExternalCommand" "DbCatFlapping" "DbCatCheck" "DbCatLog" "DbCatNotification" "DbCatProgramStatus" "DbCatRetention" "DbCatStateHistory"))

(setq icinga2-global-variables-keywords '("IcingaPrefixDir" "IcingaSysconfDir" "IcingaLocalStateDir" "IcingaPkgDataDir" "IcingaStatePath" "IcingaPidPath" "IcingaMacros" "ApplicationType" "IcingaEnableNotifications" "IcingaEnableEventHandlers" "IcingaEnableEventHandlers" "IcingaEnableChecks" "IcingaEnablePerfdata"))

(setq icinga2-macros-keywords '("HOSTNAME" "HOSTDISPLAYNAME" "HOSTALIAS" "HOSTSTATE" "HOSTSTATEID" "HOSTSTATETYPE" "HOSTATTEMPT" "MAXHOSTATTEMPT" "LASTHOSTSTATE" "LASTHOSTSTATEID" "LASTHOSTSTATETYPE" "LASTHOSTSTATECHANGE" "HOSTDURATIONSEC" "HOSTLATENCY" "HOSTEXECUTIONTIME" "HOSTOUTPUT" "HOSTPERFDATA" "LASTHOSTCHECK" "HOSTADDRESS" "HOSTADDRESS6" "SERVICEDESC" "SERVICEDISPLAYNAME" "SERVICECHECKCOMMAND" "SERVICESTATE" "SERVICESTATEID" "SERVICESTATETYPE" "SERVICEATTEMPT" "MAXSERVICEATTEMPT" "LASTSERVICESTATE" "LASTSERVICESTATEID" "LASTSERVICESTATETYPE" "LASTSERVICESTATECHANGE" "SERVICEDURATIONSE" "SERVICELATENCY" "SERVICEEXECUTIONTIME" "SERVICEOUTPUT" "SERVICEPERFDATA" "LASTSERVICECHECK" "TOTALHOSTSERVICES" "TOTALHOSTSERVICESOK" "TOTALHOSTSERVICESWARNING" "TOTALHOSTSERVICESUNKNOWN" "TOTALHOSTSERVICESCRITICAL" "USERNAME" "USERDISPLAYNAME" "USEREMAIL" "USERPAGER" "TIMET" "LONGDATETIME" "SHORTDATETIME" "DATE" "TIME"))

;; create the regex string for each class of keywords
(setq icinga2-keywords-regexp (regexp-opt icinga2-attribute-keywords 'words))
(setq icinga2-type-regexp (regexp-opt icinga2-category-keywords 'words))
(setq icinga2-constant-regexp (regexp-opt icinga2-global-variables-keywords 'words))
(setq icinga2-event-regexp (regexp-opt icinga2-cleanup-items-keywords 'words))
(setq icinga2-functions-regexp (regexp-opt icinga2-macros-keywords 'words))

;; clear memory
(setq icinga2-keywords nil)
(setq icinga2-types nil)
(setq icinga2-constants nil)
(setq icinga2-events nil)
(setq icinga2-functions nil)

;; create the list for font-lock.
;; each class of keyword is given a particular face
(setq icinga2-font-lock-keywords
      `(
	(,icinga2-type-regexp . font-lock-type-face)
	(,icinga2-constant-regexp . font-lock-constant-face)
	(,icinga2-event-regexp . font-lock-builtin-face)
	(,icinga2-functions-regexp . font-lock-function-name-face)
	(,icinga2-keywords-regexp . font-lock-keyword-face)))

;; command to comment/uncomment text
(defun icinga2-comment-dwim (arg)
  "Comment or uncomment current line or region in a smart way. For detail, see `comment-dwim'."
  (interactive "*P")
  (require 'newcomment)
  (let (
        (comment-start "//") (comment-end "")
        )
    (comment-dwim arg)))

;; syntax table
(defvar icinga2-syntax-table nil "Syntax table for `icinga2-mode'.")
(setq icinga2-syntax-table
      (let ((synTable (make-syntax-table)))

	;; C++ style comment “// …”
	(modify-syntax-entry ?\/ ". 12b" synTable)
	(modify-syntax-entry ?\n "> b" synTable)

        synTable))

;; completion
(setq icinga2-keyword-list (append icinga2-attribute-keywords icinga2-cleanup-items-keywords icinga2-category-keywords icinga2-global-variables-keywords icinga2-macros-keywords))

(defun icinga2-complete-symbol ()
  "Perform keyword completion on word before cursor."
  (interactive)
  (let ((posEnd (point))
        (meat (thing-at-point 'symbol))
        maxMatchResult)

    ;; when nil, set it to empty string, so user can see all lang's keywords.
    ;; if not done, try-completion on nil result lisp error.
    (when (not meat) (setq meat ""))
    (setq maxMatchResult (try-completion meat icinga2-keyword-list))

    (cond ((eq maxMatchResult t))
          ((null maxMatchResult)
           (message "Can't find completion for “%s”" meat)
           (ding))
          ((not (string= meat maxMatchResult))
           (delete-region (- posEnd (length meat)) posEnd)
           (insert maxMatchResult))
          (t (message "Making completion list…")
             (with-output-to-temp-buffer "*Completions*"
               (display-completion-list
                (all-completions meat icinga2-keyword-list)
                meat))
             (message "Making completion list…%s" "done")))))

;; clear memory
(setq icinga2-keywords-regexp nil)
(setq icinga2-types-regexp nil)
(setq icinga2-constants-regexp nil)
(setq icinga2-events-regexp nil)
(setq icinga2-functions-regexp nil)

;; modify the keymap

(global-set-key (kbd "M-TAB") 'icinga2-complete-symbol)

(defvar icinga2-mode-map nil "Keymap for `icinga2-mode'")

(progn
  (setq icinga2-mode-map (make-sparse-keymap))
  (define-key icinga2-mode-map (kbd "C-j") 'newline-and-indent)
  (define-key icinga2-mode-map (kbd "M-TAB") 'icinga2-complete-symbol))

;; define the mode
(define-derived-mode icinga2-mode fundamental-mode
  "Major mode for editing Icinga2 configuration files"

  :syntax-table icinga2-syntax-table
  ;; code for syntax highlighting
  (setq font-lock-defaults '((icinga2-font-lock-keywords))))

(provide 'icinga2-mode)
