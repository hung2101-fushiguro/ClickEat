package com.clickeat.listener;

import com.clickeat.dal.impl.OrderDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class OrderTimeoutListener implements ServletContextListener {

    // Bộ lập lịch chạy ngầm
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Khởi tạo 1 luồng (thread) chạy ngầm riêng biệt, không làm lag web
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // Định nghĩa công việc sẽ làm
        Runnable releaseOrdersTask = new Runnable() {
            @Override
            public void run() {
                try {
                    OrderDAO dao = new OrderDAO();
                    int releasedCount = dao.releaseExpiredOrders();

                    if (releasedCount > 0) {
                        System.out.println("======================================================");
                        System.out.println("[HỆ THỐNG AUTO] Vừa thu hồi " + releasedCount + " đơn hàng do Shipper ngâm quá 30 phút!");
                        System.out.println("======================================================");
                    }
                } catch (Exception e) {
                    System.err.println("[LỖI AUTO] Không thể chạy quét đơn: " + e.getMessage());
                }
            }
        };

        // BẮT ĐẦU CHẠY: Chờ 1 phút rồi chạy lần đầu, sau đó cứ ĐÚNG 1 PHÚT LẶP LẠI 1 LẦN
        scheduler.scheduleAtFixedRate(releaseOrdersTask, 1, 1, TimeUnit.MINUTES);
        System.out.println("[HỆ THỐNG] Đã bật bộ Radar quét đơn hàng quá hạn (1 phút/lần)");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            System.out.println("[HỆ THỐNG] Đã tắt an toàn bộ quét đơn hàng.");
        }
    }
}
