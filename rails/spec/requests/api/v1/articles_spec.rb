require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  require "rails_helper"

  RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }

    before { create_list(:article, 2, user: other_user) }

    context "ログインユーザーに紐づく articles レコードが存在する時" do
      before { create_list(:article, 3, user: current_user) }

      it "正常にレコードを取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
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

    context ":id がログインユーザーに紐づく articles レコードの id である時" do
      let(:current_user_article) { create(:article, user: current_user) }
      let(:id) { current_user_article.id }

      it "正常にレコードを取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end

    context ":id がログインユーザーに紐づく articles レコードの id ではない時" do
      let(:other_user_article) { create(:article) }
      let(:id) { other_user_article.id }

      it "例外が発生する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET api/v1/articles" do
    subject { get(api_v1_articles_path(params)) }

    before do
      create_list(:article, 25, status: :published)
      create_list(:article, 8, status: :draft)
    end

    context "page を params で送信しない時" do
      let(:params) { nil }

      it "1ページ目のレコード10件取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["articles", "meta"]
        expect(res["articles"].length).to eq 10
        expect(res["articles"][0].keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["articles"][0]["user"].keys).to eq ["name"]
        expect(res["meta"].keys).to eq ["current_page", "total_pages"]
        expect(res["meta"]["current_page"]).to eq 1
        expect(res["meta"]["total_pages"]).to eq 3
        expect(response).to have_http_status(:ok)
      end
    end

    context "page を params で送信した時" do
      let(:params) { { page: 2 } }

      it "該当ページ目のレコード10件取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["articles", "meta"]
        expect(res["articles"].length).to eq 10
        expect(res["articles"][0].keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["articles"][0]["user"].keys).to eq ["name"]
        expect(res["meta"].keys).to eq ["current_page", "total_pages"]
        expect(res["meta"]["current_page"]).to eq 2
        expect(res["meta"]["total_pages"]).to eq 3
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET api/v1/articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    let(:article) { create(:article, status:) }

    context "article_id に対応する articles レコードが存在する時" do
      let(:article_id) { article.id }

      context "articles レコードのステータスが公開中の時" do
        let(:status) { :published }

        it "正常にレコードを取得できる" do
          subject
          res = JSON.parse(response.body)
          expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
          expect(res["user"].keys).to eq ["name"]
          expect(response).to have_http_status(:ok)
        end
      end

      context "articles レコードのステータスが下書きの時" do
        let(:status) { :draft }

        it "ActiveRecord::RecordNotFound エラーが返る" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "article_id に対応する articles レコードが存在しない時" do
      let(:article_id) { 10_000_000_000 }

      it "ActiveRecord::RecordNotFound エラーが返る" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end