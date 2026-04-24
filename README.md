# plantdb
A gardener's diary and handbook, online

# Supabase limits
on the free supabase plan with these limits: nlimited API requests                                                                           
   50,000 monthly active users
   500 MB database size                                                                               
   Shared CPU • 500 MB RAM                                                                               
   5 GB egress                                                                                                                                  
   5 GB cached egress                                                                                                                  
   1 GB file storage in theory how many users would i be able to store in the database erring on the  side of caution?                          
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
✦ Erring on the side of caution, you can likely store between 15,000 and 20,000 users on the Supabase free plan before hitting the 500MB
  database limit.

  While the plan allows for 50,000 Monthly Active Users (MAU), that is a limit on the Authentication service. For a data-heavy app like a garden
  tracker, you will almost certainly hit the 500MB Database Size limit first.

  Here is the breakdown of the "Cautionary Math":

  1. The Data per User (The "Weight")
  A typical user in your app has:
   * Profile: ~1 KB (Display name, detected location, completed_tasks JSON).
   * User Plants: ~2 KB (Assuming they grow ~20 plants).
   * Planting Tracker: ~10 KB (The "heavy" part: 2–3 batches per plant, each batch having multiple date fields).
   * Wishlist: ~2 KB (A few items with notes).
   * Database Overhead: ~10 KB (Auth internal tables, audit logs, and Indices—Postgres indices often take up 30% of your total storage).

  Estimated Total per User: ~25 KB.

  2. The Capacity Calculation
   * Limit: 512,000 KB (500 MB).
   * Safety Margin: You should never run a database at 100% capacity. Aim for 80% (400 MB) to keep performance snappy.
   * Math: $400,000\text{ KB} / 25\text{ KB per user} = \mathbf{16,000 \text{ users}}$.

  3. Other Limiting Factors
   * Egress (Bandwidth): 5GB is plenty for text (JSON), but if you allow users to upload high-res photos of their seedlings to Supabase Storage,
     you will hit the 5GB Egress limit long before you hit the 500MB DB limit.
   * RAM (500MB): If you have 50,000 users all trying to sync their gardens at the same time (e.g., a Sunday morning in spring), the shared CPU
     and 500MB RAM will struggle, causing the app to feel slow.

  Summary Recommendation
   * For 1–5,000 users: You are completely safe and the app will be very fast.
   * For 10,000+ users: You should monitor the "Database Size" chart in your Supabase dashboard closely. 
   * Strategy: If you reach the limit, you can optimize by moving "old" tracking data (from previous years) into a separate "Archive" table or
     flat file to keep the active database small.
