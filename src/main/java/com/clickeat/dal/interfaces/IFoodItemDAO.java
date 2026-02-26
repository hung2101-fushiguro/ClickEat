package com.clickeat.dal.interfaces;

import com.clickeat.model.FoodItem;
import java.util.List;

public interface IFoodItemDAO extends IGenericDAO<FoodItem> {
    
    // Lấy danh sách món ăn nổi bật (isAvailable = true)
    List<FoodItem> getTopFoods(int limit);
    
    // Lấy món ăn theo quán
    List<FoodItem> findByMerchant(int merchantUserId);
    
    // Tìm kiếm
    List<FoodItem> searchByName(String keyword);
}