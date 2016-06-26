require "spec_helper"

describe Diaspora::Federation::Dispatcher do
  let(:post) { FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: true) }
  let(:opts) { {service_types: "Services::Twitter"} }

  describe ".build" do
    it "creates a public dispatcher for a public post" do
      expect(Diaspora::Federation::Dispatcher::Public).to receive(:new).with(alice, post, opts).and_call_original

      dispatcher = described_class.build(alice, post, opts)

      expect(dispatcher).to be_instance_of(Diaspora::Federation::Dispatcher::Public)
    end

    it "creates a private dispatcher for a private post" do
      private = FactoryGirl.create(:status_message, author: alice.person, text: "hello", public: false)

      expect(Diaspora::Federation::Dispatcher::Private).to receive(:new).with(alice, private, opts).and_call_original

      dispatcher = described_class.build(alice, private, opts)

      expect(dispatcher).to be_instance_of(Diaspora::Federation::Dispatcher::Private)
    end

    it "creates a private dispatcher for object with no public flag" do
      object = double

      expect(Diaspora::Federation::Dispatcher::Private).to receive(:new).with(alice, object, {}).and_call_original

      dispatcher = described_class.build(alice, object)

      expect(dispatcher).to be_instance_of(Diaspora::Federation::Dispatcher::Private)
    end
  end

  describe ".defer_dispatch" do
    it "queues a job for dispatch" do
      expect(Workers::DeferredDispatch).to receive(:perform_async).with(alice.id, "StatusMessage", post.id, opts)
      described_class.defer_dispatch(alice, post, opts)
    end
  end
end