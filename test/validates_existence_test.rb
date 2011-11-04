require File.dirname(__FILE__) + '/init'

  # Blog
  class Blog < ActiveRecord::Base
    has_many :posts
  end

  # Post
  class Post < ActiveRecord::Base
    belongs_to :blog
    has_many :comments, :as => :commentable
  end

  class PostWithRequiredBlog < Post
    validates_existence_of :blog
  end

  class PostWithoutRequiredBlog < Post
    validates_existence_of :blog, :allow_nil => true
  end
  
  class PostWithRequiredBlogIf < Post
    validates_existence_of :blog, :if => :condition
    attr_accessor :condition
  end
  
  class PostWithRequiredBlogUnless < Post
    validates_existence_of :blog, :unless => :condition
    attr_accessor :condition
  end

  # Comment
  class Comment < ActiveRecord::Base
    belongs_to :commentable, :polymorphic => true
  end

  class CommentWithRequiredCommentable < Comment
    validates_existence_of :commentable
  end

  class CommentWithoutRequiredCommentable < Comment
    validates_existence_of :commentable, :allow_nil => true
  end


class ValidatesExistenceTest < Test::Unit::TestCase
  
  def setup
    create_all_tables
    @default_blog = Blog.create
    @default_post = PostWithoutRequiredBlog.create
  end

  def teardown
    drop_all_tables
  end
  
  # PostWithRequiredBlog
  
    def test_should_create_post_with_required_blog_with_valid_blog
      obj = PostWithRequiredBlog.new :blog_id => @default_blog.id
      assert obj.valid?

      obj = PostWithRequiredBlog.new :blog => @default_blog
      assert obj.valid?
    end
  
    def test_should_not_create_post_with_required_blog_when_blog_is_nil
      obj = PostWithRequiredBlog.new
      assert !obj.valid?
      assert obj.errors.on(:blog)
    end

    def test_should_create_post_with_required_blog_when_blog_does_exist
      obj = PostWithRequiredBlog.new :blog_id => nil, :blog => @default_blog
      assert obj.valid?
    end
  
    def test_should_not_create_post_with_required_blog_when_blog_does_not_exist
      obj = PostWithRequiredBlog.new :blog_id => '2'
      assert !obj.valid?
      assert obj.errors.on(:blog)
    end

    def test_should_create_post_with_required_blog_when_blog_is_a_new_blog
      obj = PostWithRequiredBlog.new :blog => Blog.new
      assert obj.valid?
    end
  
  # PostWithoutRequiredBlog
  
    def test_should_create_post_without_required_blog_with_valid_blog
      obj = PostWithoutRequiredBlog.new :blog_id => @default_blog.id
      assert obj.valid?
    end

    def test_should_create_post_without_required_blog_with_a_new_blog
      obj = PostWithoutRequiredBlog.new :blog => Blog.new
      assert obj.valid?
    end
  
    def test_should_create_post_without_required_blog_when_blog_is_nil
      obj = PostWithoutRequiredBlog.new
      assert obj.valid?
    end
  
    def test_should_not_create_post_without_required_blog_when_blog_does_not_exist
      obj = PostWithoutRequiredBlog.new :blog_id => '2'
      assert !obj.valid?
      assert obj.errors.on(:blog)
    end
    
  # Polymorphic CommentWithRequiredCommentable
  
    def test_should_create_comment_with_required_commentable_with_valid_commentable
      obj = CommentWithRequiredCommentable.new :commentable_id => @default_post.id, :commentable_type => 'Post'
      assert obj.valid?
    end

    def test_should_create_comment_with_required_commentable_with_a_new_commentable
      obj = CommentWithRequiredCommentable.new :commentable => Post.new
      assert obj.valid?
    end
  
    def test_should_not_create_comment_with_required_commentable_when_commentable_is_nil
      obj = CommentWithRequiredCommentable.new
      assert !obj.valid?
      assert obj.errors.on(:commentable)
    end
  
    def test_should_not_create_comment_with_required_commentable_when_commentable_does_not_exist
      obj = CommentWithRequiredCommentable.new :commentable_id => '2', :commentable_type => 'Post'
      assert !obj.valid?
      assert obj.errors.on(:commentable)
    end
    
  # Polymorphic CommentWithoutRequiredCommentable
  
    def test_should_create_comment_without_required_commentable_with_valid_commentable
      obj = CommentWithoutRequiredCommentable.new :commentable_id => @default_post.id, :commentable_type => 'Post'
      assert obj.valid?
    end

    def test_should_create_comment_without_required_commentable_with_a_new_commentable
      obj = CommentWithoutRequiredCommentable.new :commentable => Post.new
      assert obj.valid?
    end
  
    def test_should_create_comment_without_required_commentable_when_commentable_is_nil
      obj = CommentWithoutRequiredCommentable.new
      assert obj.valid?
    end
  
    def test_should_not_create_comment_without_required_commentable_when_commentable_does_not_exist
      obj = CommentWithoutRequiredCommentable.new :commentable_id => '2', :commentable_type => 'Post'
      assert !obj.valid?
      assert obj.errors.on(:commentable)
    end
    
  # PostWithRequiredBlogIf (:if => :condition)
  
    def test_post_should_require_blog_when_if_condition_is_true
      obj = PostWithRequiredBlogIf.new
      obj.condition = true
      assert !obj.valid?
    end
    
    def test_post_should_not_require_blog_when_if_condition_is_false
      obj = PostWithRequiredBlogIf.new
      obj.condition = false
      assert obj.valid?
    end
    
  # PostWithRequiredBlogUnless (:unless => :condition)

    def test_post_should_require_blog_when_unless_condition_is_false
      obj = PostWithRequiredBlogUnless.new
      obj.condition = false
      assert !obj.valid?
    end
    
    def test_post_should_not_require_blog_when_unless_condition_is_true
      obj = PostWithRequiredBlogUnless.new
      obj.condition = true
      assert obj.valid?
    end
  
end
