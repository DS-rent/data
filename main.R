library(readr)
library(dplyr)
library(stringr)

# 設定資料夾路徑
base_path <- "rawdata"

# 遞迴找出所有 A_lvr_land_C.csv 路徑
file_list <- list.files(path = base_path, pattern = "A_lvr_land_C.csv", recursive = TRUE, full.names = TRUE)

# 建立輸出資料夾
dir.create("dataset", showWarnings = FALSE)

# 建立一個 list 用來儲存每份處理完的資料框
all_data <- list()

# 對每個檔案進行處理
for (file in file_list) {
  cat("處理中：", file, "\n")
  
  # 嘗試用 UTF-8 或 BIG5 讀取
  df <- tryCatch({
    read_csv(file, locale = locale(encoding = "UTF-8"))
  }, error = function(e) {
    read_csv(file, locale = locale(encoding = "BIG5"))
  })

  # 過濾並選擇所需欄位
  df_clean <- df %>%
    filter(土地面積平方公尺 != "0.0") %>%
    select(
      鄉鎮市區,
      土地面積平方公尺,
      租賃年月日,
      租賃層次,
      建物型態,
      單價元平方公尺
    ) %>%
    mutate(across(everything(), ~str_trim(as.character(.))))

  # 儲存個別檔案
  name <- basename(dirname(file))
  output_file <- file.path("dataset", paste0(name, "_clean.csv"))
  write_csv(df_clean, output_file)

  # 將清理資料加入 list
  all_data[[length(all_data) + 1]] <- df_clean
}

# 合併所有資料並輸出成總表
combined_df <- bind_rows(all_data)
write_csv(combined_df, "dataset/all_cleaned.csv")

cat("✅ 所有清理後資料已合併儲存為 dataset/all_cleaned.csv\n")
