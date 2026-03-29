class BreedDetector
  # Breed to typical characteristics mapping
  BREED_DATA = {
    # Small breeds
    "chihuahua" => { size: "small", typical_weight: 2.5, temperament_hints: ["energetic", "nervous"] },
    "pomeranian" => { size: "small", typical_weight: 3, temperament_hints: ["energetic"] },
    "yorkshire terrier" => { size: "small", typical_weight: 3, temperament_hints: ["energetic"] },
    "maltese" => { size: "small", typical_weight: 3, temperament_hints: ["calm"] },
    "shih tzu" => { size: "small", typical_weight: 6, temperament_hints: ["calm"] },
    "cavalier king charles" => { size: "small", typical_weight: 7, temperament_hints: ["calm"] },
    "french bulldog" => { size: "small", typical_weight: 11, temperament_hints: ["calm"] },
    "pug" => { size: "small", typical_weight: 8, temperament_hints: ["calm"] },
    "dachshund" => { size: "small", typical_weight: 9, temperament_hints: ["energetic"] },
    "miniature poodle" => { size: "small", typical_weight: 6, temperament_hints: ["calm", "energetic"] },
    "jack russell" => { size: "small", typical_weight: 7, temperament_hints: ["energetic"] },
    "bichon frise" => { size: "small", typical_weight: 5, temperament_hints: ["calm"] },
    
    # Medium breeds
    "cocker spaniel" => { size: "medium", typical_weight: 13, temperament_hints: ["calm", "energetic"] },
    "beagle" => { size: "medium", typical_weight: 11, temperament_hints: ["energetic"] },
    "border collie" => { size: "medium", typical_weight: 18, temperament_hints: ["energetic"] },
    "australian shepherd" => { size: "medium", typical_weight: 23, temperament_hints: ["energetic"] },
    "bulldog" => { size: "medium", typical_weight: 23, temperament_hints: ["calm"] },
    "staffordshire bull terrier" => { size: "medium", typical_weight: 15, temperament_hints: ["energetic"] },
    "springer spaniel" => { size: "medium", typical_weight: 23, temperament_hints: ["energetic"] },
    "whippet" => { size: "medium", typical_weight: 12, temperament_hints: ["calm", "nervous"] },
    "standard poodle" => { size: "medium", typical_weight: 27, temperament_hints: ["calm"] },
    "labradoodle" => { size: "medium", typical_weight: 25, temperament_hints: ["energetic"] },
    "cockapoo" => { size: "medium", typical_weight: 10, temperament_hints: ["energetic"] },
    
    # Large breeds  
    "labrador" => { size: "large", typical_weight: 32, temperament_hints: ["calm", "energetic"] },
    "golden retriever" => { size: "large", typical_weight: 32, temperament_hints: ["calm"] },
    "german shepherd" => { size: "large", typical_weight: 35, temperament_hints: ["calm", "reactive"] },
    "rottweiler" => { size: "large", typical_weight: 50, temperament_hints: ["calm"] },
    "boxer" => { size: "large", typical_weight: 30, temperament_hints: ["energetic"] },
    "doberman" => { size: "large", typical_weight: 40, temperament_hints: ["energetic"] },
    "husky" => { size: "large", typical_weight: 25, temperament_hints: ["energetic"] },
    "dalmatian" => { size: "large", typical_weight: 27, temperament_hints: ["energetic"] },
    "weimaraner" => { size: "large", typical_weight: 35, temperament_hints: ["energetic", "anxious"] },
    "vizsla" => { size: "large", typical_weight: 25, temperament_hints: ["energetic"] },
    
    # Giant breeds
    "great dane" => { size: "giant", typical_weight: 60, temperament_hints: ["calm"] },
    "saint bernard" => { size: "giant", typical_weight: 75, temperament_hints: ["calm"] },
    "newfoundland" => { size: "giant", typical_weight: 60, temperament_hints: ["calm"] },
    "irish wolfhound" => { size: "giant", typical_weight: 55, temperament_hints: ["calm"] },
    "bernese mountain dog" => { size: "giant", typical_weight: 45, temperament_hints: ["calm"] },
    "mastiff" => { size: "giant", typical_weight: 80, temperament_hints: ["calm"] },
    "great pyrenees" => { size: "giant", typical_weight: 50, temperament_hints: ["calm"] }
  }.freeze

  def self.detect_from_breed(breed_name)
    return {} if breed_name.blank?
    
    normalized = breed_name.downcase.strip
    
    # Direct match
    if BREED_DATA[normalized]
      return BREED_DATA[normalized]
    end
    
    # Partial match
    BREED_DATA.each do |breed, data|
      if normalized.include?(breed) || breed.include?(normalized)
        return data
      end
    end
    
    # Fuzzy match - check for common breed words
    BREED_DATA.each do |breed, data|
      breed_words = breed.split
      normalized_words = normalized.split
      if (breed_words & normalized_words).any?
        return data
      end
    end
    
    {}
  end

  def self.detect_size_from_weight(weight_kg)
    return nil unless weight_kg.present?
    
    case weight_kg
    when 0..10 then "small"
    when 10..25 then "medium"
    when 25..45 then "large"
    else "giant"
    end
  end

  def self.is_puppy?(age_string)
    return false if age_string.blank?
    
    normalized = age_string.downcase
    return true if normalized.include?("puppy")
    return true if normalized.include?("weeks")
    
    # Check for age in months/years
    if match = normalized.match(/(\d+)\s*(month|year|yr|mo)/)
      num = match[1].to_i
      unit = match[2]
      
      if unit.start_with?("month") || unit == "mo"
        return num < 12
      elsif unit.start_with?("year") || unit == "yr"
        return num < 1
      end
    end
    
    false
  end

  def self.is_senior?(age_string, breed_name = nil)
    return false if age_string.blank?
    
    normalized = age_string.downcase
    return true if normalized.include?("senior")
    
    if match = normalized.match(/(\d+)\s*(year|yr)/)
      years = match[1].to_i
      
      # Large/giant breeds age faster
      breed_data = detect_from_breed(breed_name)
      threshold = case breed_data[:size]
                  when "giant" then 6
                  when "large" then 7
                  when "medium" then 8
                  else 10
                  end
      
      return years >= threshold
    end
    
    false
  end
end
