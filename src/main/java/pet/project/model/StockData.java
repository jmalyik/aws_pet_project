package pet.project.model;

import java.math.BigDecimal;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StockData {
	
	  public String symbol;
      public BigDecimal price;
      public BigDecimal changePercent;
}
