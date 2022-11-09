# Tạo Swap
createSwap() {
  # Chạy lệnh dd tạo 2GB swap (count=2046k), dung lượng Swap tối đa chỉ nên gấp đôi RAM vật lý
	sudo dd if=/dev/zero of=/swapfile bs=1024 count=2046k
	
  # Tạo phân vùng swap
  sudo mkswap /swapfile
  
  # Kích hoạt swap
	sudo swapon /swapfile
  
  # Thiết lập swap tự động được kích hoạt mỗi khi reboot
	sudo echo /swapfile none swap defaults 0 0 >> /etc/fstab
  
  # Bảo mật file swap bằng cách chmod
	sudo chown root:root /swapfile 
	sudo chmod 600 /swapfile
  
  # Swappiness là mức độ ưu tiên sử dụng swap, khi lượng RAM còn lại bằng giá trị của swappiness (tính theo tỷ lệ phần trăm) thì swap sẽ được sử dụng.
  # Swappiness có giá trị trong khoảng 0 – 100.
  # swappiness = 0: swap chỉ được dùng khi RAM được sử dụng hết.
  # swappiness = 10: swap được sử dụng khi RAM còn 10%.
  # swappiness = 60: swap được sử dụng khi RAM còn 60%.
  # swappiness = 100: swap được ưu tiên như là RAM.
  # Do tốc độ xử lý dữ liệu trên RAM cao hơn nhiều so với Swap, do đó bạn nên đặt giá trị này về gần với 0 để tận dụng tối đa sức mạnh hệ thống.
  # Tốt nhất nên chỉnh về 10. Chỉnh thông số swappiness bằng cách dùng lệnh sysctl
  sudo sysctl vm.swappiness=10
  
  # Để đảm bảo giữ nguyên thông số này mỗi khi khởi động lại VPS bạn cần điều chỉnh tham số vm.swappiness ở cuối file /etc/sysctl.conf
  
  # Define the filename
  filename='/etc/sysctl.conf'
  textAppend= 'vm.swappiness = 10'

  # Check the new text is empty or not
  if [ $textAppend != "" ]; then
      # Append the text by using `tee` command
      echo $textAppend | tee -a  $filename > /dev/null
  fi
  
  sudo swapon -s
  sudo cat /proc/sys/vm/swappiness
}
# RUN
createSwap

# Khởi động lại VPS và kiểm tra lại kết quả:
# swapon -s
# cat /proc/sys/vm/swappiness
