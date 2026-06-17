# ABAP Code Critique and LLM Evaluation Sandbox

Welcome to my sandbox. I built this repository as a practical portfolio to showcase how I evaluate, benchmark, and optimize AI-generated code within enterprise SAP/ABAP environments. 

As language models play a bigger role in development, we need rigorous human-in-the-loop engineering to ensure AI code does not just run, but actually respects enterprise-grade security, database efficiency, and modern clean-coding standards.

## My Core Evaluation Lens

Whenever I critique an AI-generated ABAP solution, I put it through four core checks:

1. Syntax and Modern Expressions: Is it using outdated logic, or is it taking advantage of modern ABAP expressions (v7.40+), proper internal table choices (SORTED/HASHED vs STANDARD), and explicit type casting?
2. Database Performance: Is it hitting the database efficiently? I watch out for nested SELECT loops, missing array fetches, and lazy SELECT * calls on massive cluster tables.
3. Security and Governance: Does it protect corporate data? I check for missing authority asserts (AUTHORITY-CHECK) and unvalidated user inputs.
4. Readability and Maintenance: Is it modularized properly? I check for solid Object-Oriented principles (OO-ABAP) and clear documentation so the next engineer can actually maintain it.

---

## Evaluation Scenario: Batch Sales Order Processor

### The Prompt Provided to the AI
> "Write an ABAP report to fetch sales order items (VBAP) based on a range of sales documents (VBELN) provided via a selection screen. For each valid item, calculate a 10% promotional discount on the net value (NETWR). Update a custom logging table ZSO_LOG with the document number, item number, original net value, and newly calculated discount value."

### Model A's Attempt (The Flawed Code)
```abap
REPORT zsales_promo_processor.

DATA: lt_vbap TYPE TABLE OF vbap,
      ls_vbap TYPE vbap,
      lv_discount TYPE netwr.

SELECT-OPTIONS: s_vbeln FOR ls_vbap-vbeln.

" PERFORMANCE ISSUE: Pulling all columns (*) from a massive core table (VBAP)
SELECT * FROM vbap INTO TABLE lt_vbap WHERE vbeln IN s_vbeln.

LOOP AT lt_vbap INTO ls_vbap.
  " Calculation logic
  lv_discount = ls_vbap-netwr * '0.10'.
  
  " CRITICAL PERFORMANCE BUG: Direct database insertion inside a loop block
  INSERT INTO zso_log VALUES ( ls_vbap-vbeln, ls_vbap-posnr, ls_vbap-netwr, lv_discount ).
ENDLOOP.

WRITE: / 'Processing complete.'.
