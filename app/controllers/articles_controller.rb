class ArticlesController < ApplicationController
  before_action :set_target_article, only: %i[show edit update destroy]
  before_action :set_ranking_data


  def index
    @articles = Article.all
    # ids = REDIS.zrevrangebyscore "posts/daily/#{Date.today.to_s}", "inf", 0, limit:[0, 2]
    # @ranking_articles = ids.map{| id |Article.find(id)}
  end

  def new
    @article = Article.new
    @form_name = "Create"

  end

  def create
    article = Article.create(article_params)
    redirect_to article
  end

  def show
    # 個別ページのアクセスをカウント
    REDIS.zincrby("articles/daily/#{Date.today.to_s}", 1, @article.title)

  end

  def edit
    @form_name = "Update"
    redirect_to root_path, alert: "Not yours" unless current_user.email == @article.name

  end

  def update
    @article.update(article_params)
    redirect_to @article
  end

  def destroy
    if current_user.email == @article.name
      @article.destroy
      REDIS.zrem("articles/daily/#{Date.today.to_s}", @article.title)
      redirect_to root_path
    else
      redirect_to root_path, alert: "Not yours"
    end
  end

  def set_ranking_data
    titles = REDIS.zrevrangebyscore "articles/daily/#{Date.today.to_s}", "+inf", 0, limit: [0, 3],with_scores: true
    @ranking_articles = Hash[*titles.flatten]
  end



  private

    def article_params
      params.require(:article).permit(:title, :body, :name)
    end

    def set_target_article
      @article = Article.find(params[:id])
    end
end
