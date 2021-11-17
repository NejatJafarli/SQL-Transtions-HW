--EN : Implement stored procedures for rating comments and posts.
--AZ : Comment və postlara reytinq vermək üçün stored prosedurlar yazın.

CREATE PROCEDURE AddCommentMark
@Commit INT,
@UserId INT,
@Mark INT
AS
BEGIN
     BEGIN TRAN CommentMark
        INSERT INTO CommentRating(IdComment,IdUser,Mark)VALUES
        (@Commit,@UserId,@Mark)

        IF (@@ERROR != 0)
            BEGIN
                PRINT 'Error In Insert'
                ROLLBACK TRAN CommentMark
            END
        ELSE
            BEGIN
                PRINT 'Insert OK'

                UPDATE Comments SET Rating = 
			   (
                SELECT CAST(SUM(Mark) AS float) / COUNT(*) FROM Comments 
                JOIN CommentRating ON Comments.Id = CommentRating.IdComment 
                WHERE Comments.Id = @Commit
               )

               WHERE Comments.Id = @Commit

            IF (@@ERROR != 0)
                BEGIN
                    PRINT 'Error In UPDATE'
                    ROLLBACK TRAN CommentMark
                END
            ELSE 
				BEGIN
					PRINT 'UPDATE OK'
					COMMIT TRAN CommentMark
				END
        END
END

GO

EXEC AddCommentMark 2,3,4

GO
--AZ : Nəzərə alın ki , commentə xal verildiyi halda siz commentin 
--və bu commenti yazan userin reytiniqini yenidən hesablamalısınız. 
--Bu elementlər hamısı eyni bir tranzasiyada baş verməlidir.

CREATE PROCEDURE AddCalculateUsersCommentMark
@Commit INT,
@UserId INT,
@Mark INT
AS
BEGIN
     BEGIN TRAN CommentMark
        INSERT INTO CommentRating(IdComment,IdUser,Mark)VALUES
        (@Commit,@UserId,@Mark)

        IF (@@ERROR != 0)
            BEGIN
                PRINT 'Error In Insert'
                ROLLBACK TRAN CommentMark
            END
        ELSE
            BEGIN
                PRINT 'Insert OK'

                UPDATE Comments SET Rating = 
			   (
                SELECT CAST(SUM(Mark) AS float) / COUNT(*) FROM Comments 
                JOIN CommentRating ON Comments.Id = CommentRating.IdComment 
                WHERE Comments.Id = @Commit
               )

               WHERE Comments.Id = @Commit

            IF (@@ERROR != 0)
                BEGIN
                    PRINT 'Error In UPDATE'
                    ROLLBACK TRAN CommentMark
                END
            ELSE 
				BEGIN
					PRINT 'UPDATE OK'

					UPDATE Users SET Rating=(
						SELECT SUM(Comments.Rating) / COUNT(*) 
						FROM Comments 
						WHERE Comments.IdUser=@UserId)
					WHERE Users.Id=@UserId

					IF (@@ERROR!=0)
						BEGIN
							PRINT 'Update 2 ERROR'
							ROLLBACK TRAN CommentMark
						END
					ELSE
						BEGIN
							PRINT 'Update 2 is OK'
							COMMIT TRAN CommentMark
						END

				END
        END
END

EXEC AddCalculateUsersCommentMark 1,3,4

GO

--EN : Similarly with posts. When an evaluation of
--the post is made, it is necessary to recalculate the 
--rating of the post and the rating of the user who wrote this post.
--AZ : Eyni ilə yuxarıda yazılanlar postlara da aiddir.


------------------------------------------------
CREATE PROCEDURE AddPostMark
@PostId INT,
@UserId INT,
@Mark INT
AS
BEGIN
     BEGIN TRAN PostMark
        INSERT INTO PostRating(IdPost,IdUser,Mark)VALUES
        (@PostId,@UserId,@Mark)

        IF (@@ERROR != 0)
            BEGIN
                PRINT 'Error In Insert'
                ROLLBACK TRAN PostMark
            END
        ELSE
            BEGIN
                PRINT 'Insert OK'

                UPDATE Posts SET Rating = 
			   (
                SELECT CAST(SUM(Mark) AS float) / COUNT(*) FROM Posts 
                JOIN PostRating ON Posts.Id = PostRating.IdPost 
                WHERE Posts.Id = @PostId
               )

               WHERE Posts.Id = @PostId

            IF (@@ERROR != 0)
                BEGIN
                    PRINT 'Error In UPDATE'
                    ROLLBACK TRAN PostMark
                END
            ELSE 
				BEGIN
					PRINT 'UPDATE OK'
					COMMIT TRAN PostMark
				END
        END
END

GO
-----------------------------------------------------



CREATE PROCEDURE AddCalculateUserRatingPostMark
@PostId INT,
@UserId INT,
@Mark INT
AS
BEGIN
     BEGIN TRAN PostMark
        INSERT INTO PostRating(IdPost,IdUser,Mark)VALUES
        (@PostId,@UserId,@Mark)

        IF (@@ERROR != 0)
            BEGIN
                PRINT 'Error In Insert'
                ROLLBACK TRAN PostMark
            END
        ELSE
            BEGIN
                PRINT 'Insert OK'

                UPDATE Posts SET Rating = 
			   (
                SELECT CAST(SUM(Mark) AS float) / COUNT(*) FROM Posts 
                JOIN PostRating ON Posts.Id = PostRating.IdPost 
                WHERE Posts.Id = @PostId
               )

               WHERE Posts.Id = @PostId

            IF (@@ERROR != 0)
                BEGIN
                    PRINT 'Error In UPDATE'
                    ROLLBACK TRAN PostMark
                END
            ELSE 
				PRINT 'UPDATE OK'

					UPDATE Users SET Rating=(
						SELECT SUM(Posts.Rating) / COUNT(*) 
						FROM Posts 
						WHERE Posts.IdUser=@UserId)
					WHERE Users.Id=@UserId

					IF (@@ERROR!=0)
						BEGIN
							PRINT 'Update 2 ERROR'
							ROLLBACK TRAN PostMark
						END
					ELSE
						BEGIN
							PRINT 'Update 2 is OK'
							COMMIT TRAN PostMark
						END

				END
        END
END

















