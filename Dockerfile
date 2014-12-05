# rbenv Docker image
# ---------------------------------------
# envelonment
# --------------------------
FROM phusion/baseimage:0.9.15
MAINTAINER Ryoh Kawai <kawairyoh@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# --------------------------
# first setup
# --------------------------
# Install packages for building ruby
ENV DEBIAN_FRONTED nointeractive
RUN dpkg-divert --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl

#------------------------------------------------
# Change apt repository site and update
#------------------------------------------------
RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#http://jp.archive.ubuntu.com/ubuntu/#g' /etc/apt/sources.list && \
    apt-get update

#------------------------------------------------
# Install Base Software
#------------------------------------------------
RUN apt-get install -y sudo ack-grep zsh lv vim-nox curl && \
    chmod +s /usr/bin/sudo

#------------------------------------------------
# Vim 7.4 (enabled python3 interface)
#------------------------------------------------
ADD ./package/deb/vim/amd64 /tmp/deb
RUN dpkg -i /tmp/deb/vim-tiny_7.4.052-1ubuntu4_amd64.deb \
            /tmp/deb/vim-common_7.4.052-1ubuntu4_amd64.deb \
            /tmp/deb/vim-runtime_7.4.052-1ubuntu4_all.deb \
            /tmp/deb/vim-nox_7.4.052-1ubuntu4_amd64.deb \
            /tmp/deb/vim_7.4.052-1ubuntu4_amd64.deb \
            && apt-get -f install

#------------------------------------------------
# Install Dev tools
#------------------------------------------------
RUN apt-get install -y git-core make bison gcc cpp g++ autoconf build-essential

#------------------------------------------------
# Install rubyenv libraries
#------------------------------------------------
RUN apt-get install -y zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev ncurses-dev
RUN apt-get install -y sqlite3 libsqlite3-0 libsqlite3-dev

#------------------------------------------------
# Cache clean
#------------------------------------------------
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#------------------------------------------------
# Add ruby user
#------------------------------------------------
ADD ./vimrc /etc/skel/.vimrc
RUN adduser --disabled-password --gecos "" ruby && \
    echo "ruby ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ruby && \
    locale-gen ja_JP ja_JP.UTF-8 && dpkg-reconfigure locales && \
    echo "ruby:ruby" | chpasswd
USER ruby
WORKDIR /home/ruby
ENV HOME /home/ruby

#------------------------------------------------
# Install rbenv and ruby-build
#------------------------------------------------
RUN git clone https://github.com/sstephenson/rbenv.git              ${HOME}/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git         ${HOME}/.rbenv/plugins/ruby-build
RUN git clone https://github.com/sstephenson/rbenv-default-gems.git ${HOME}/.rbenv/plugins/rbenv-default-gems
RUN git clone https://github.com/sstephenson/rbenv-gem-rehash.git   ${HOME}/.rbenv/plugins/rbenv-gem-rehash
RUN git clone https://github.com/rkh/rbenv-update.git               ${HOME}/.rbenv/plugins/rbenv-update
ENV PATH ./bundle_bin:${HOME}/.rbenv/bin:${HOME}/bin:$PATH

#------------------------------------------------
# Install multiple versions of ruby
#------------------------------------------------
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./versions.txt ${HOME}/versions.txt
ADD ./default-gems ${HOME}/.rbenv/default-gems
ADD ./gemrc        ${HOME}/.gemrc
ADD ./bundle       ${HOME}/.bundle
RUN xargs -L 1 rbenv install < ${HOME}/versions.txt
RUN bash -l -c "for v in $(cat ${HOME}/versions.txt); do rbenv global $v; done"
RUN echo 'export LANG=ja_JP.UTF-8' >> ${HOME}/.bashrc && \
    echo 'export LC_ALL=ja_JP.UTF-8' >> ${HOME}/.bashrc && \
    echo 'export PATH="./bundle_bin:${HOME}/.rbenv/bin:${HOME}/bin:$PATH"' >> ${HOME}/.bashrc &&  \
    echo 'eval "$(rbenv init -)"' >> ${HOME}/.bashrc

#------------------------------------------------
# vimrc
#------------------------------------------------
RUN mkdir -p .vim/bundle
RUN git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
RUN git clone https://github.com/Shougo/vimproc.vim   ~/.vim/bundle/vimproc.vim && \
    cd ~/.vim/bundle/vimproc.vim && \
    make
RUN cd ~/.vim/bundle/neobundle.vim/bin && ./neoinstall

#------------------------------------------------
# git
#------------------------------------------------
ADD ./.gitignore_global /home/ruby/.gitignore_global
ADD ./.gitconfig        /home/ruby/.gitconfig

ENV DEBIAN_FRONTED dialog
