class DeviseMailer < Devise::Mailer
  default from: "#{Gitlab.config.doggohub.email_display_name} <#{Gitlab.config.doggohub.email_from}>"
  default reply_to: Gitlab.config.doggohub.email_reply_to

  layout 'devise_mailer'

  protected

  def subject_for(key)
    subject = super
    subject << " | #{Gitlab.config.doggohub.email_subject_suffix}" if Gitlab.config.doggohub.email_subject_suffix.present?
    subject
  end
end
