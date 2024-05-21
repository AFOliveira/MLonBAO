import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Sample data
data = {
    "Setup": ["Solo", "Solo+CC", "Interf", "Interf+CC"],
    "MnistC-CNN": [1.0964, 1.4174, 2.8332, 4.1641],
    "MnistC-DNN": [0.1271, 0.1655, 0.7865, 0.6515],
    "Cifar10-CNN": [1.6542, 2.1392, 3.7291, 5.8499]
}

# Creating DataFrame
df = pd.DataFrame(data)
df.set_index("Setup", inplace=True)

# Transposing DataFrame for plotting
df_t = df.transpose()

# Normalize data relative to the "Solo" setup
df_t = df_t.div(df_t["Solo"], axis=0)

# Custom colors for the bars
colors = {
    "Solo": "#D9D9D9",
    "Solo+CC": "#BFBFBF",
    "Interf": "#A6A6A6",
    "Interf+CC": "#8C8C8C"
}

# Background colors for each category
bg_colors = ['#5E81AC', '#60AC7C', '#486C8E']

# Setting up the figure and axes
fig, ax = plt.subplots(figsize=(8, 5))
fig.patch.set_facecolor('white')  # Set the overall figure background to white

# Bar width and space between groups
bar_width = 0.15
x = np.arange(len(df_t.index))  # x-coordinates for the groups

# Adding background colors only around the columns
for i, bg_color in enumerate(bg_colors):
    start = x[i] - 0.5 + bar_width / 2
    end = x[i] + 0.5 - bar_width / 2
    ax.axvspan(start, end, color=bg_color, alpha=0.3)

# Plotting each column with custom offsets
for i, column in enumerate(df_t.columns):
    offsets = x + i * bar_width - ((len(df_t.columns) * bar_width) / 2 - bar_width / 2)
    ax.bar(offsets, df_t[column], width=bar_width, color=colors[column], label=column)

# Adding horizontal grid lines
ax.yaxis.grid(True, linestyle='--', linewidth=0.5, color='grey')
ax.xaxis.grid(False)  # Removing vertical grid lines

# Customizing the plot
plt.xlabel("")
plt.ylabel("Performance Relative to Solo", fontsize=12)
plt.xticks(x, df_t.index, rotation=0, fontsize=10)  # Set x-ticks to be the model names
plt.title("")

# Adjusting legend
plt.legend(title="Setup", title_fontsize='13', fontsize='11', loc='upper left')

# Final adjustments and showing the plot
plt.tight_layout()
plt.show()