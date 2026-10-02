/**
 * Reference data that is not in the librarians' spreadsheet: the library's
 * sections and the publication cities. Both were curated earlier and are
 * authoritative — the books sheet only *points* at them, so the seed maps
 * its free-text values onto these ids and never invents a new row.
 */

export interface DepartmentRef {
  id: string;
  nameEn: string;
  nameAr: string;
}

export interface PlaceRef {
  id: string;
  nameEn: string;
  nameAr: string;
}

export const DEPARTMENTS: DepartmentRef[] = [
  { id: "d_electrical", nameEn: "Electrical Engineering", nameAr: "كهرباء" },
  { id: "d_architecture", nameEn: "Architecture", nameAr: "عمارة" },
  { id: "d_civil", nameEn: "Civil Engineering", nameAr: "هندسة مدنية" },
  { id: "d_mechanical", nameEn: "Mechanical Engineering", nameAr: "هندسة ميكانيكية" },
  { id: "d_basic_sciences", nameEn: "Basic Sciences", nameAr: "علوم أساسية" },
  { id: "d_periodicals", nameEn: "Periodicals", nameAr: "دوريات علمية" },
  { id: "d_theses", nameEn: "Theses", nameAr: "رسائل علمية" },
  { id: "d_reference", nameEn: "Reference Books", nameAr: "مراجع" },
];

export const PLACES: PlaceRef[] = [
  { id: "scranton", nameEn: "Scranton", nameAr: "سکرانتون" },
  { id: "new-delhi", nameEn: "New Delhi", nameAr: "نيودلهي" },
  { id: "tehran", nameEn: "Tehran", nameAr: "طهران" },
  { id: "new-york", nameEn: "New York", nameAr: "نيويورك" },
  { id: "hoboken", nameEn: "Hoboken", nameAr: "هوبوكين" },
  { id: "cairo", nameEn: "Cairo", nameAr: "القاهرة" },
  { id: "giza", nameEn: "Giza", nameAr: "الجيزة" },
  { id: "beirut", nameEn: "Beirut", nameAr: "بيروت" },
  { id: "new-jersey", nameEn: "New Jersey", nameAr: "نيو جيرسي" },
  { id: "alexandria", nameEn: "Alexandria", nameAr: "الإسكندرية" },
  { id: "boston", nameEn: "Boston", nameAr: "بوسطن" },
  { id: "oman", nameEn: "Oman", nameAr: "عمان" },
  { id: "oxford", nameEn: "Oxford", nameAr: "أكسفورد" },
  { id: "cambridge", nameEn: "Cambridge", nameAr: "كامبريدج" },
  { id: "upper-saddle-river", nameEn: "Upper Saddle River", nameAr: "أبر سادل ريفر" },
  { id: "basingstoke", nameEn: "Basingstoke", nameAr: "بيسينغستوك" },
  { id: "hardcover", nameEn: "Hardcover", nameAr: "هاردكوفر" },
  { id: "houndmills-basingstoke", nameEn: "Houndmills, Basingstoke", nameAr: "هاوندملز، بيسينغستوك" },
  { id: "iran", nameEn: "Iran", nameAr: "إيران" },
  { id: "korea", nameEn: "Korea", nameAr: "كوريا" },
  { id: "london", nameEn: "London", nameAr: "لندن" },
  { id: "reading-massachusetts", nameEn: "Reading, Massachusetts", nameAr: "ريدينغ، ماساتشوستس" },
  { id: "seoul", nameEn: "Seoul", nameAr: "سيول" },
  { id: "sterling", nameEn: "Sterling", nameAr: "ستيرلينغ، فرجينيا" },
  { id: "usa", nameEn: "USA", nameAr: "الولايات المتحدة الأمريكية" },
  { id: "washington", nameEn: "Washington", nameAr: "واشنطن" },
  { id: "paperback", nameEn: "Paperback", nameAr: "غلاف ورقي" },
];
