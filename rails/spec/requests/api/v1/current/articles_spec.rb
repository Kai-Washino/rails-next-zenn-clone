require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      create_list(:article, 2, user: other_user)
    end

    context "ログインユーザーに紐づく articles レコードが存在する時" do
      before do
        create_list(:article, 3, user: current_user)
      end

      it "正常にレコードを取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "content", "status", "created_at", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインユーザーに紐づく articles レコードが存在しない時" do
      it "空の配列が返る" do
        subject
        res = JSON.parse(response.body)
        expect(res).to eq []
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET api/v1/current/articles/:id" do
    subject { get(api_v1_current_article_path(id), headers:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }

    context ":id がログインユーザーに紐づく articles レコードの id である時" do
      let(:current_user_article) { create(:article, user: current_user) }
      let(:id) { current_user_article.id }

      it "正常にレコードを取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "updated_at", "user"]
        expect(res["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end

    context ":id がログインユーザーに紐づく articles レコードの id ではない時" do
      let(:other_user_article) { create(:article, user: other_user) }
      let(:id) { other_user_article.id }

      it "例外が発生する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end