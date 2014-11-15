require 'spec_helper'

describe CommonMailer do
  describe 'plain' do
    let(:mail) { CommonMailer.plain(from: 'from@example.com',
                                    to: 'to@example.org',
                                    subject: 'Hello!',
                                    body: 'World!') }

    it 'renders the headers' do
      expect(mail).to deliver_from('from@example.com')
      expect(mail).to deliver_to('to@example.org')
      expect(mail).to have_subject('Hello!')
    end

    it 'renders the body' do
      expect(mail).to have_body_text(/World!/)
    end
  end
end
