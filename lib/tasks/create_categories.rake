namespace :db do
  namespace :seed do
    desc 'Create default categories'
    task create_categories: :environment do
      categories = ['History', 'Philosophy', 'Religion and Spirituality', 'Science', 'Politics',
                    'Social Sciences', 'Essay', 'Self-Help', 'Business',
                    'Economics and Finance', 'Health and Wellness', 'Crafts and Hobbies', 'Academic Texts',
                    'Language Books', 'Arts Books', 'Memoirs and autobiographies', 'Biographies',
                    'Journalism', 'Guides and How To Manuals', 'Various']

      categories.each { |cat| Category.create! name: cat, slug: name.downcase.gsub(/ /, '-') }
    end
  end
end
