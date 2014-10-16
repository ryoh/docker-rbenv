FROM ubuntu:14.04

MAINTAINER Ryoh Kawai <kawairyoh@gmail.com>

# Install packages for building ruby
ENV DEBIAN_FRONTED nointeractive
RUN chmod go+w,u+s /tmp
RUN dpkg-divert --local --rename --add /sbin/initctl && \
    rm -f /sbin/initctl && \
    ln -s /bin/true /sbin/initctl
RUN sed -i.bak 's/archive/jp.archive/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git mercurial subversion exuberant-ctags \
    python-setuptools python-software-properties vim-nox autoconf bison openssl automake libtool
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev ncurses-dev
RUN apt-get install -y --force-yes sqlite3 libsqlite3-0 libsqlite3-dev
RUN apt-get clean

# Install rbenv and ruby-build
ENV RBENV_ROOT /usr/local/rbenv
RUN git clone https://github.com/sstephenson/rbenv.git              ${RBENV_ROOT}
RUN git clone https://github.com/sstephenson/ruby-build.git         ${RBENV_ROOT}/plugins/ruby-build
RUN git clone https://github.com/sstephenson/rbenv-default-gems.git ${RBENV_ROOT}/plugins/rbenv-default-gems
RUN git clone https://github.com/sstephenson/rbenv-gem-rehash.git   ${RBENV_ROOT}/plugins/rbenv-gem-rehash
RUN git clone https://github.com/rkh/rbenv-update.git               ${RBENV_ROOT}/plugins/rbenv-update
ENV PATH ${RBENV_ROOT}/bin:$PATH
ADD ./rbenv.sh /etc/profile.d/rbenv.sh

# Install multiple versions of ruby
WORKDIR /root
ENV HOME /root
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./versions.txt /root/versions.txt
ADD ./default-gems ${RBENV_ROOT}/default-gems
ADD ./.gemrc       /root/.gemrc
ADD ./.bundle      /root/.bundle
RUN echo 'PATH=./bundle_bin:${PATH}' >> /etc/skel/.bashrc && \
    cat   /etc/profile.d/rbenv.sh    >> /etc/skel/.bashrc && \
    cp    /root/.gemrc                  /etc/skel/.gemrc && \
    cp -R /root/.bundle                 /etc/skel/.bundle
RUN xargs -L 1 rbenv install < /root/versions.txt
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; done'

# Add User
ADD ./vimrc /etc/skel/.vimrc
RUN adduser --disabled-password --gecos "" ruby && \
    echo "ruby ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "ruby:ruby" | chpasswd
RUN chown -R ruby /usr/local/rbenv && \
    chmod g+w -R /usr/local/rbenv

# Setup
USER ruby
WORKDIR /home/ruby
ENV HOME /home/ruby

# vim
RUN mkdir -p .vim/bundle
RUN git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
RUN git clone https://github.com/Shougo/vimproc.vim   ~/.vim/bundle/vimproc.vim && \
    cd ~/.vim/bundle/vimproc.vim && \
    make
RUN cd ~/.vim/bundle/neobundle.vim/bin && ./neoinstall

# git
ADD ./.gitignore_global /home/ruby/.gitignore_global
ADD ./.gitconfig        /home/ruby/.gitconfig

ENV DEBIAN_FRONTED dialog
