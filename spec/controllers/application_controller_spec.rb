require "rails_helper"

# Testea el filtro redirect_to_canonical directamente porque el harness de
# request specs normaliza el trailing slash antes de llegar al controller.
RSpec.describe ApplicationController do
  def run_canonical_filter(path)
    req = ActionDispatch::TestRequest.create
    req.set_header("PATH_INFO", path)
    ctrl = described_class.new
    ctrl.set_request!(req)
    ctrl.set_response!(described_class.make_response!(req))
    ctrl.send(:redirect_to_canonical)
    ctrl.response
  end

  describe "#redirect_to_canonical" do
    it "redirige 301 quitando el trailing slash" do
      res = run_canonical_filter("/es/teams/brasil/")
      expect(res.status).to eq(301)
      expect(res.location).to end_with("/es/teams/brasil")
      expect(res.location).not_to end_with("/es/teams/brasil/")
    end

    it "no redirige la home ('/')" do
      res = run_canonical_filter("/")
      expect(res.status).not_to eq(301)
      expect(res.location).to be_nil
    end

    it "no redirige una URL sin trailing slash" do
      res = run_canonical_filter("/es/teams/brasil")
      expect(res.status).not_to eq(301)
      expect(res.location).to be_nil
    end
  end
end
