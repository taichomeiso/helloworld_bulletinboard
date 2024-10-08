class PostsController < ApplicationController
  def index
    @posts = Post.all.order(created_at: :desc)
    @post = Post.new
  
    respond_to do |format|
      format.html # HTML形式のレスポンス（通常のビューが必要）
       format.json { render json: @posts }
    end
  end
  
  def search
    @posts = Post.search(params[:keyword])
  end

  def latest
    # 最新の投稿を取得 (例: 直近10件)
    latest_posts = Post.order(created_at: :desc).limit(10)
    # 必要なデータだけを返す
    render json: latest_posts.as_json(include: { user: { only: [:id, :nickname] } }, methods: [:image_url])
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user || User.guest
  
    respond_to do |format|
      if @post.save
        format.json { render json: @post.as_json(include: { user: { only: [:id, :nickname] } }, methods: [:image_url]), status: :created }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @post = Post.find_by(id: params[:id]) # find_byを使用
    if @post.nil?
      render 'not-found', status: :not_found
      return
    end
    @comments = @post.comments.includes(:user)
    @comment = Comment.new
    @from_my_page = params[:from] == 'mypage'

    respond_to do |format|
      format.html
      format.json { render json: { post: @post, comments: @comments } }
    end
  end
  
  def edit
    @post = Post.find(params[:id])
    
    respond_to do |format|
      format.html # 通常のHTMLリクエスト
      format.json { render json: { form: render_to_string(partial: 'edit-form', locals: { post: @post }, formats: [:html]) } }
    end
  end
  
  def update
    @post = Post.find(params[:id])
  
    time_difference = Time.current - @post.created_at
  
    if time_difference > 600
      respond_to do |format|
        format.json { render json: { error: '投稿の編集期限が切れています。' }, status: :forbidden }
      end
      return
    end
  
    if @post.user.id != (current_user&.id || User.guest.id)
      respond_to do |format|
        format.json { render json: { error: 'この投稿の編集権限がありません。' }, status: :forbidden }
      end
      return
    end
  
    if @post.update(post_params)
      respond_to do |format|
        format.json { render json: { message: '投稿が更新されました。', post: @post }, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
  
    # 投稿の作成時間と現在の時間の差を計算
    time_difference = Time.current - @post.created_at
  
    # 30分(1800秒)以内かどうかをチェック

    if time_difference <= 1800 && @post.user.id == (current_user&.id || User.guest.id)
      if @post.destroy
        flash[:notice] = "投稿が削除されました。"
        redirect_to root_path
      else
        flash[:alert] = "投稿の削除に失敗しました。再試行してください。"
        redirect_back(fallback_location: post_path(@post.id))
      end
    else
      flash[:alert] = "投稿は投稿したユーザーかつ30分以内にしか削除できません。"
      redirect_back(fallback_location: post_path(@post.id))
    end
    
  end
  


  private

  def post_params
    params.require(:post).permit(:title, :content, :image).merge(user_id: current_user&.id || User.guest.id)
  end
  
end