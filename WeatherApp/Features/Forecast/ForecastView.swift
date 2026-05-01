  //
//  ForecastView.swift
//  WeatherApp
//
//  Created by Mehmet Fışkındal on 8.09.2023.
//

import SwiftUI
import Charts


struct ForecastView: View {
  @ObservedObject private var forecastViewModel: ForecastViewModel = ForecastViewModel()
  @State private var city: String = ""
  
  var body: some View {
    NavigationView {
      VStack {
        VStack {
          TextField("Şehir Adı Girin", text: $city)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
          Button(action: {
            Task {
              await forecastViewModel.fetchForecast(city: city)
            }
          }) {
            Text("Tahminleri Getir")
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
          }
        }
        .padding(.all, 10.0)
        
        WeatherChartView(forecastViewModel: forecastViewModel,
                         kelvinToCelsius: forecastViewModel.kelvinToCelsius,
                         dateFormatter: forecastViewModel.dateFormatter,
                         forecastList: forecastViewModel.forecastList ?? [])
          .frame(height: 300)
        
        ForecastListView(forecastViewModel: forecastViewModel,
                         kelvinToCelsius: forecastViewModel.kelvinToCelsius,
                         dateFormatter: forecastViewModel.dateFormatter,
                         forecastList: forecastViewModel.forecastList ?? [])
      }
      .navigationBarTitle("Hava Durumu")
      .navigationBarItems(trailing: Button(action: {}) {
        Image(systemName: "gearshape")
      })
    }
  }
}
struct ForecastListView: View {
  var forecastViewModel: ForecastViewModel
  var kelvinToCelsius: (Double) -> Int
  var dateFormatter: DateFormatter
  var forecastList: [Liste]

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .top, spacing: 10) {
        ForEach(forecastList.indices, id: \.self) { index in
          let data = forecastList[index]

          if let date = dateFormatter.date(from: data.dtTxt ?? "") {
            VStack(alignment: .leading) {
              Text(date, style: .date)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.vertical, 5)

              ForecastListViewItem(data: data, kelvinToCelsius: kelvinToCelsius)
            }
            .frame(width: 200)  // Adjust the width as needed
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
          }
        }
      }
      .padding(.horizontal, 10)
    }
    .padding(.vertical, 10)
  }
}

struct ForecastListViewItem: View {
  let data: Liste
  let kelvinToCelsius: (Double) -> Int
  var body: some View {
    VStack(alignment: .center) {
      VStack(alignment: .leading, spacing: 5) {
        HStack{
          Text("Sıcaklık:")
            .fontWeight(.semibold)
          Text("\(kelvinToCelsius(data.main?.temp ?? 0))°C")
            .font(.title2)
        }
        HStack{
          Text("Rüzgar Hızı:")
            .fontWeight(.semibold)
          Text(data.wind?.speed?.description ?? " ")
            .font(.title2)
        }
        HStack{
          Text("Nem:")
            .fontWeight(.semibold)
          Text(data.main?.humidity?.description ?? " ").font(.title2)
        }
        VStack{
          HStack{
            Text("Basınç:")
              .fontWeight(.semibold)
            Text(data.main?.pressure?.description ?? " ").font(.title2)
            Spacer()
          }
          HStack{
            Text("\(data.dtTxt ?? " ")")
          Spacer()
          }
        }
      }
    }
    .padding(.vertical, 10)
  }
}
struct WeatherChartView: View {
  var forecastViewModel: ForecastViewModel
  var kelvinToCelsius: (Double) -> Int
  var dateFormatter: DateFormatter
  var forecastList: [Liste]
  
  var body: some View {
    Chart {
      ForEach(forecastList, id: \.dt) { data in
        if let dateStr = data.dtTxt,
           let date = dateFormatter.date(from: dateStr) {
          LineMark(
            x: .value("Date", date),
            y: .value("Temperature", kelvinToCelsius(data.main?.temp ?? 0))
          )
          .foregroundStyle(Color.blue)
          .symbol(Circle())
        }
      }
    }
    .chartXAxis {
      AxisMarks(values: .stride(by: .hour, count: 12)) {
        AxisGridLine()
        AxisTick()
        AxisValueLabel(format: .dateTime.hour().month().day().hour(), centered: true, orientation: .vertical)
      }
    }
    .chartYAxis {
      AxisMarks() {
        AxisGridLine()
        AxisTick()
        AxisValueLabel()
      }
    }
    .padding()
  }
}
#Preview {
  ForecastView()
}
