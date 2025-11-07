# Procrastinote  
**A minimal task manager built with SwiftUI, SwiftData, and WidgetKit.**  

Track your progress, visualize productivity, and stay accountable.

---

## 📱 Features

### Task Management
- Create, edit, and organize tasks by **category**  
- Mark tasks as complete/incomplete  
- SwiftData-backed persistence (no Core Data boilerplate)  
- SwiftUI 18 list, swipe actions, and smooth animations  

### Dashboard Analytics
- **Donut-style progress ring** showing completion percentage  
- **Bar chart** visualization of tasks by category (using Swift Charts)  
- Real-time updates via SwiftData queries  
- Clean glass-morphic `ChartCard` components  

### Home Screen Widget
- Live widget displaying your current completion rate  
- Built with WidgetKit and SwiftUI 18’s `.containerBackground()`  
- Shares data securely through an **App Group**  
- Auto-refreshes every 30 minutes or when tasks change  

---

## 🧠 Technologies
| Framework | Usage |
|------------|--------|
| **SwiftUI 18** | Declarative UI and animations |
| **SwiftData** | Persistent storage layer |
| **Charts** | In-app analytics visualization |
| **WidgetKit** | Home screen widget integration |
| **App Groups** | Secure data sharing between app and widget |
| **WidgetCenter** | On-demand widget refresh |

---

## Future Enhancements
- Interactive widgets (mark tasks done directly) using App Intents  
- Daily streaks & motivational insights  
- iCloud sync for multi-device data  
- Swift Data migration versioning  
- macOS Catalyst & visionOS dashboard

---

## Privacy & Security
All data is stored locally using SwiftData.  
No third-party analytics, no external servers, and all widget communication uses secure App Group containers.

---

## Author
**Aryan Palit**  
Computer Science @ Virginia Tech  
Passionate about Swift, system design, and Apple-native experiences.

---

## License
MIT License — see [LICENSE](LICENSE) for details.

---

> _Designed with SwiftUI 18. Built the Apple way._
