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

data_l2_misses = {
    "Setup": ["Solo", "Solo+CC", "Interf", "Interf+CC"],
    "MnistC-CNN": [303010431, 291653275, 462448780, 325860538],
    "MnistC-DNN": [7941910, 7817241, 203717586, 76865113],
    "Cifar10-CNN": [139232247, 142811218, 189535866, 148053353]
}

# data_bus_cycles = {
#     "Setup": ["Solo", "Solo+CC", "Interf", "Interf+CC"],
#     "MnistC-CNN": [5360314868, 7962237013, 14394048192, 20008983476],
#     "MnistC-DNN": [1472515089, 2185880991, 6927004043, 5940784161],
#     "Cifar10-CNN": [2407793555, 3567997524, 6020695679, 8769085510]
# }
data_bus_cycles = {
    "Setup": ["Solo", "Solo+CC", "Interf", "Interf+CC"],
    "MnistC-CNN": [3.876, 5.957, 4.392, 9.311],
    "MnistC-DNN": [33.180, 49.901, 4.763, 10.274],
    "Cifar10-CNN": [3.722, 5.395, 4.440, 9.097]
}
# Creating DataFrame
df = pd.DataFrame(data)
df.set_index("Setup", inplace=True)

# Creating DataFrame
df2 = pd.DataFrame(data_l2_misses)
df2.set_index("Setup", inplace=True)


# Creating DataFrame
df3 = pd.DataFrame(data_bus_cycles)
df3.set_index("Setup", inplace=True)

# Transposing DataFrame for plotting
df_t = df.transpose()
df2_t = df2.transpose()
df3_t = df3.transpose()

# Normalize data relative to the "Solo" setup
df_t = df_t.div(df_t["Solo"], axis=0)
df2_t = df2_t.div(df2_t["Solo"], axis=0)
df3_t = df3_t.div(df3_t["Solo"], axis=0)

# Custom colors for the bars
colors = {
    "Solo": "#D9D9D9",
    "Solo+CC": "#BFBFBF",
    "Interf": "#A6A6A6",
    "Interf+CC": "#8C8C8C"
}

# Background colors for each category
bg_colors = ['#2171B5', '#6BAED6', '#60AC7C']

# Setting up the figure and axes
fig, ax = plt.subplots(2, 2, figsize=(10, 12))  # 2 Rows, 1 Column
fig.patch.set_facecolor('white')  # Set the overall figure background to white

# Bar width and space between groups
bar_width = 0.15
x = np.arange(len(df_t.index))  # x-coordinates for the groups

# Adding horizontal grid lines
ax[0,0].yaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)
ax[0,0].xaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)  # Adding vertical grid lines

# Adding background colors only around the columns (adjusted for increased height)
for i, bg_color in enumerate(bg_colors):
    start = x[i] - 0.5 + bar_width / 2
    end = x[i] + 0.5 - bar_width / 2
    # Adjusted y-values for background spans to cover full height
    ax[0,0].axvspan(start, end, color=bg_color, alpha=0.3, ymin=0, ymax=1) 

# Plotting each column with custom offsets
for i, column in enumerate(df_t.columns):
    offsets = x + i * bar_width - ((len(df_t.columns) * bar_width) / 2 - bar_width / 2)
    ax[0,0].bar(offsets, df_t[column], width=bar_width, color=colors[column], label=column,
              edgecolor='black', linewidth=1)

# Customizing the plot (with legend positioning adjustments)
ax[0,0].set_ylabel("Inference Time Relative to Solo", fontsize=12)
ax[0,0].set_xticks(x)
ax[0,0].set_xticklabels(df_t.index, rotation=0, fontsize=10)
# Adjust legend position for better visibility and add border
legend = ax[0,0].legend(title="Setup", title_fontsize='13', fontsize='11', loc='upper right', bbox_to_anchor=(1, 1.1))

ax[0,0].yaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)
ax[0,0].xaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)  # Adding vertical grid lines

# Adding background colors only around the columns (adjusted for increased height)
for i, bg_color in enumerate(bg_colors):
    start = x[i] - 0.5 + bar_width / 2
    end = x[i] + 0.5 - bar_width / 2
    # Adjusted y-values for background spans to cover full height
    ax[1,0].axvspan(start, end, color=bg_color, alpha=0.3, ymin=0, ymax=1) 

# Plotting each column with custom offsets
for i, column in enumerate(df2_t.columns):
    offsets = x + i * bar_width - ((len(df2_t.columns) * bar_width) / 2 - bar_width / 2)
    ax[1,0].bar(offsets, df2_t[column], width=bar_width, color=colors[column], label=column,
              edgecolor='black', linewidth=1)

# Customizing the plot (with legend positioning adjustments)
ax[1,0].set_ylabel("L2 Misses Relative to Solo", fontsize=12)
ax[1,0].set_xticks(x)
ax[1,0].set_xticklabels(df2_t.index, rotation=0, fontsize=10)
# Adjust legend position for better visibility and add border

legend.get_frame().set_linewidth(1)
legend.get_frame().set_edgecolor('black')  

ax[1,0].yaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)
ax[1,0].xaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)  # Adding vertical grid lines


# Adding background colors only around the columns (adjusted for increased height)
for i, bg_color in enumerate(bg_colors):
    start = x[i] - 0.5 + bar_width / 2
    end = x[i] + 0.5 - bar_width / 2
    # Adjusted y-values for background spans to cover full height
    ax[1,1].axvspan(start, end, color=bg_color, alpha=0.3, ymin=0, ymax=1) 

# Plotting each column with custom offsets
for i, column in enumerate(df3_t.columns):
    offsets = x + i * bar_width - ((len(df2_t.columns) * bar_width) / 2 - bar_width / 2)
    ax[1,1].bar(offsets, df3_t[column], width=bar_width, color=colors[column], label=column,
              edgecolor='black', linewidth=1)

# Customizing the plot (with legend positioning adjustments)
ax[1,1].set_ylabel("Bus Cycles Relative to Solo", fontsize=12)
ax[1,1].set_xticks(x)
ax[1,1].set_xticklabels(df3_t.index, rotation=0, fontsize=10)
# Adjust legend position for better visibility and add border
#legend = ax[1,1].legend(title="Setup", title_fontsize='13', fontsize='11', loc='upper right', bbox_to_anchor=(1, 1.1))

legend.get_frame().set_linewidth(1)
legend.get_frame().set_edgecolor('black')  

ax[1,1].yaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)
ax[1,1].xaxis.grid(True, linestyle='--', color='grey', linewidth=0.3)  # Adding vertical grid lines


# Final adjustments and showing the plot
legend = ax[0,1].legend(title="Setup", title_fontsize='13', fontsize='11', loc='upper right', bbox_to_anchor=(1, 1.1))
plt.tight_layout()
plt.show()

