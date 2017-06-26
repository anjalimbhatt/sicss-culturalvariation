GeoText -- Geo-tagged Microblog Corpus
=======================================

URL: http://www.ark.cs.cmu.edu/GeoText
Version: 2010-10-12

The dataset is described in the following paper.
Please consider citing it if appropriate. Thanks!

  "A Latent Variable Model for Geographic Lexical Variation."
  Jacob Eisenstein, Brendan O'Connor, Noah A. Smith, and Eric P. Xing.
  http://www.cs.cmu.edu/~nasmith/papers/eisenstein+oconnor+smith+xing.emnlp10.pdf
  In Proceedings of the Conference on Empirical Methods in Natural Language Processing, Cambridge, MA, 2010.

Contact brenocon@cmu.edu with any questions.


Overview
========

377616 messages from 9475 geo-located microblog users approximately within the
United States, over one week in March 2010.  See the 'Data' section of the
paper for more details.


Contents
========

full_text.txt   --  All messages and meta information, in tab-separated fields.

processed_data/
  data.mat      --  Matlab format.  Key variables are
    w_data         -- (User ID, "document position", word ID) triples
    u_lat, u_long  -- Coordinates per user.

  Main plaintext-formatted data:
  user_info     --  Geo coordinates per user (from their first message)
                    User IDs correspond to line numbers in this file.
  vocab_wc_dc   --  Vocabulary file, with word and doc counts. 
                    Word IDs correspond to line numbers in this file.
  user_pos_word --  (User ID, docposition, word ID) triples

  Other versions:
  user_word_tf  --  Normalized TF features per user, triples format.
  {train,dev,test}.dat  --  Word counts per user, "LDA" format.

preproc/        --  Scripts for constructing some of the above files
                    from full_text.txt.

geo_eval/       --  Scripts we used for location prediction evaluation.
                    A little messy; not all are used.
                    geo_dist.py is the most (only?) useful one.

"Document position" means the position in the document obtained from
concatenating all the user's messages together.

Train/Dev/Test splits
=====================

Train, Dev, and Test splits are by user ID.
Folds are numbered 1,2,3,4,5, 1,2,3,4,5, across users
  i.e., fold = (userID % 5); fold = fold==0 ? 5 : fold  

Training set is folds 1,2,3
Dev set is fold 4
Test set is fold 5

Some files already have train,dev,test splitted versions.


De-identification
=================

All messages were public Twitter messages posted in March 2010.

Even so, we have taken an additional, if modest, step of anonymizing usernames
in the author field as well as @-mentions.  This certainly does not ensure
privacy, but makes casual searching for individual users a little harder.

