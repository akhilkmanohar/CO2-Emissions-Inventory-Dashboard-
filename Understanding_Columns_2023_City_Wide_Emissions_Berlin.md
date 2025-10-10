# 🧾 Understanding the columns in `2023_City_Wide_Emissions_Berlin.csv`

The CDP dataset (like the one you downloaded for **Berlin**) follows the **GHG Protocol** and **CDP Cities questionnaire** structure.  
So let’s go over the **most important columns** in your CSV and what each one actually means — in *simple terms* 👇  

---

| **Column name** | **Meaning (Simple Explanation)** | **Example / Notes** |
|------------------|----------------------------------|---------------------|
| **Questionnaire** | The reporting form that city used (e.g., *Cities 2023*). | Tells you which year’s CDP form this came from. |
| **Organization ID** | CDP’s unique ID for the city. | Berlin has a number like *31153* – just an internal reference. |
| **City / State / Region Name** | Name of the reporting city or region. | “Berlin” |
| **Country** | Country name. | “Germany” |
| **Region** | World region grouping used by CDP. | “Europe” |
| **Access Level** | Whether the data is *public* or restricted. | “Public” (you can use it freely) |
| **C40 Member** | Whether the city is a member of the C40 Cities Climate Leadership Group. | “True” means yes. |
| **Global Protocol Standard** | The GHG accounting standard followed — usually *Global Protocol for Community-Scale GHG Inventories (GPC)*. | This aligns with GHG Protocol scopes 1, 2, 3. |
| **Gases Included** | Greenhouse gases counted. | Usually “CO₂, CH₄, N₂O” (converted to CO₂e). |
| **Primary Emissions Metric** | The unit used. | “tCO₂e” = tonnes of CO₂ equivalent. |
| **Emissions Type** | Describes the type: “Direct emissions,” “Indirect,” or “Scope total.” | Direct = Scope 1, Indirect = Scope 2, Scope Total = sum of 1–3. |
| **Emissions Scope** | The GHG Protocol scope (1, 2, or 3). | 1 = direct (fuel), 2 = electricity, 3 = indirect (value chain). |
| **Emissions Sector / Subsector** | What part of the city the emissions come from. | E.g., “Transport,” “Residential buildings,” “Industry,” “Waste.” |
| **Emissions Value** | The actual emissions amount (numerical). | e.g., `4,300,000` tCO₂e |
| **Year of Data** | The year the emission data corresponds to. | e.g., 2019 (some cities report with 1–2 year lag). |
| **Boundary** | What area or activities were included. | “Same coverage as previous inventory” = consistent boundary. |
| **Population** | City population used for per capita calculations. | Berlin ≈ 3.6 million |
| **Tool Used** | Name of the software/tool used to compile the inventory. | “CIRIS” (Common Inventory Reporting & Information System) |
| **City Location (Lat/Lon)** | Geographic coordinates (latitude/longitude). | Helps in mapping visualization later. |
| **Last Updated** | When this record was updated on CDP. | e.g., 2024-04-03 |

---

## 🧩  How these fit your analysis

When we clean the data, you’ll only need a few key columns:

| **Keep These** | **Why** |
|----------------|---------|
| `City`, `Country`, `Region` | Identify the city and its location. |
| `Emissions Sector`, `Subsector` | To visualize emissions by activity type. |
| `Emissions Scope` | To build charts for Scope 1, 2, 3. |
| `Emissions Value` | Core metric (tCO₂e). |
| `Year of Data` | For time-based trend charts. |
| `Population` | To calculate per-capita emissions. |

Everything else (like IDs or URLs) can stay aside or be dropped for simplicity.
