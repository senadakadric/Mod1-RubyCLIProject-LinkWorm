class User < ActiveRecord::Base

    has_many :user_links
    has_many :links, through: :user_links

    @@prompt = TTY::Prompt.new

    def self.display_main_menu(user)

         @@prompt.select("Main Menu") do |m|
         m.choice "Add Link", -> {Link.add_link(user)}
         m.choice "Saved Links", -> {user.saved_links}
         m.choice "Suggested Links", -> {user.suggested_links}
         m.choice "Update Link", -> {user.update_link}
         m.choice "Remove Link", -> {user.remove_link}
         m.choice "Exit", -> {Interface.quit}
        end
    end

    def saved_links
        puts "Your saved links are:"
        self.links.each do |link|
            puts "#{link.title} - #{link.url}"
        end
        puts "--------"
        User.display_main_menu(self)
    end

    def suggested_links
        puts "These are the most popular websites!"
        puts "Google.com"
        puts "Youtube.com"
        puts "Reddit.com"
        puts "Facebook.com"
        puts "Twitter.com"
        puts "news.ycombinator.com"
        puts "Leetcode.com"
    end

    def update_link
        link_url = nil
        @@prompt.select("Updating links:") do |m|
            m.choice "Enter link url", -> {
                user_link = self.find_userlink_by_url
                #ask what they wanna do to the link
                self.choose_update_option(user_link)
            }
            #add later as stretch
            m.choice "View all links"
        end
        # @@prompt.select("Choose a link to update:") do |m|   
    end
    

    def find_userlink_by_url
        link_url = @@prompt.ask("Link url:", required: true)
        found_link = self.links.find {|link| link.url == link_url}
        if found_link
            # first find 
            userlink = self.user_links.where("link_id == ?", found_link.id)
            return userlink[0] #test later to see if can delete this
        else
            puts "Link not found... going back to main menu"
            User.display_main_menu(self)
            return nil
        end
    end

    def choose_update_option(userlink)
        choice = @@prompt.select("What do you want to do?") do |m|
            m.choice "Mark as favorite", -> {self.mark_as_fav(userlink)}
            m.choice "Mark as visited", -> {self.mark_as_visited(userlink)}
            #add later as stretch
            m.choice "Change category", -> {self.change_category(link)}
            m.choice "Update description", -> {self.update_desc(link)}
        end
        
    end

    def mark_as_fav(userlink)
        userlink.is_favorite = true
        puts "Awesome! This link has now been marked as favorite."
        User.display_main_menu(self)
    end

    def mark_as_visited(userlink)
        userlink.visited = true
        puts "Awesome! Link marked as visited."
        User.display_main_menu(self)
    end

    def remove_link
        link_to_remove = self.find_userlink_by_url
        if link_to_remove
            link_to_remove.destroy
            puts "destroyeddd"
            User.display_main_menu(self)
        end
    end
            
end