# Olympiad-2026

https://drive.google.com/drive/folders/1gqJBVC_yjLo15mP8qQcfLyKZV4lZuyjd?usp=sharing

THE PROBLEM: Who REALLY Won the Battle of USA vs. Canada at Milano Cortina 2026?

You have been hired as analysts for OlympEdge Analytics. Your mission: use real athlete data from the 2026 Winter Olympics (390 records, 17 variables) to answer a data-driven question being debated across North America:

"USA: 33 medals, 12 golds. Canada: 21 medals, 5 golds. But who truly outperformed expectations given their resources — and what must each nation do differently to win in 2030?"

Your dataset (milan_cortina_2026_athletes.csv) includes real named athletes — Mikaela Shiffrin, Jordan Stolz, Connor McDavid, Mikael Kingsbury, and more. Like all real-world data: it is intentionally messy. Finding and fixing problems is part of your grade.

YOUR FOUR TASKS (100 points + 5 bonus)

Task 1 — Data Cleaning & Preprocessing (20 pts)
• Audit all columns for missing values, errors, and duplicates
• Find all 4 planted impossible/erroneous values — all four must be identified for full marks
• Identify and remove the 3 hidden duplicate records
• Distinguish MNAR vs. MCAR missingness (Reaction_Time_ms and World_Cup_Points_Preseason are MNAR — sport-systematic, not random)
• Engineer at least 2 new meaningful features
• Produce a Before vs. After summary table

Task 2 — Exploratory Data Analysis & Storytelling (25 pts)
• Answer all 6 questions (Q2.1–Q2.6) with at least one strong visualization each
• The USA vs. Canada comparison thread must run throughout your EDA
• Minimum 8 professional-quality visualizations with labeled axes and written interpretations

Task 3 — Predictive Modeling (30 pts)
• Build a binary model: Medal vs. No Medal
• Train at least 2 model architectures; handle class imbalance explicitly (SMOTE, class weights, or threshold tuning)
• Evaluate with Accuracy, Precision, Recall, F1, and AUC-ROC
• Apply your model to the 7 specific athletes listed in the problem (Jordan Stolz, Mikaela Shiffrin, Connor McDavid, Courtney Sarault, Elana Meyers Taylor, Deanna Stellato-Dudek, Metodej Jilek) and analyze where your model succeeds or fails
• BONUS (+5 pts): Build a multi-class model predicting Gold / Silver / Bronze / None

Task 4 — Business Insight Report (25 pts)
• Write an executive-ready strategic report for the North American Winter Sports Consortium
• Include a 1-page Executive Summary that stands alone
• Cover insights for USA, Canada, the head-to-head rivalry, a 2030 blueprint, and an ethics/limitations section
• Audience: performance directors and funding committees — write for sport ministers, not statisticians

WHAT TO PAY ATTENTION TO

1. Data quality is central — don't rush cleaning. Every imputation or removal decision must be justified in writing.

2. Not all outliers are errors. A 42-year-old Olympic figure skater (Deanna Stellato-Dudek) and a 19-year-old gold medalist (Metodej Jilek) are real athletes. Do NOT remove them blindly.

3. Class imbalance: ~27% of athletes won a medal. If you ignore this, your model will be misleading. Address it explicitly and explain why accuracy alone is not sufficient.

4. The USA vs. Canada thread is not optional — it must weave through your EDA and modeling sections. Judges are looking for this narrative throughout.

5. Reproducibility is required. All code must run from your GitHub repo using your README instructions. Test this before submitting.

6. Generative AI for coding assistance is allowed — but all analysis, interpretations, and strategic thinking must be your own. Teams with identical code or analysis will be flagged.

TIMELINE

• Challenge Start:   April 25, 2025 — 3:00 PM local time
• Submission Deadline: April 27, 2025 — 4:00 PM local time (your time zone)
• Duration: 36 hours
• Team size: Exactly 4 students

HOW TO SUBMIT

Submit a single ZIP file containing:
   All reports (Tasks 1–4)
   All code files
   Signed Team Agreement (must be the FIRST document in the ZIP)

Include your GitHub repository link in the email body.
