class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com", "Content-Transfer-Encoding": "7bit"
  layout "mailer"
end
