/*
 * memory.h
 *
 *  Created on: 19.11.2020
 *      Author: shageboeck
 */

#ifndef MEMORY_H
#define MEMORY_H 1

#include "mgOnGpuConfig.h"
#include "mgOnGpuTypes.h"
#include "mgOnGpuVectors.h"

#include <memory>

template<typename T = fptype> inline
std::unique_ptr<T[]> hstMakeUnique(std::size_t N) { return std::unique_ptr<T[]>{ new T[N]() }; };

// A base class encapsulating a memory buffer (not necessarily an event buffer)
template<typename T>
class host_buffer_unique {
public:
  host_buffer_unique( const size_t size ) : m_size( size ), m_data( new T[m_size] ) {}
  virtual ~host_buffer_unique(){}

  T* data(){ return m_data.get(); }
  const T* data() const{ return m_data; }
  T& operator[]( const size_t index ){ return m_data[index]; }
  const T& operator[]( const size_t index ) const { return m_data[index]; }
  size_t size() const{ return m_size; }
  size_t bytes() const{ return m_size*sizeof(T); }
protected:
  const size_t m_size;
  std::unique_ptr<T[]> m_data;
};

#endif /* MEMORY_H */
